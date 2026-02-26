import Foundation
import SwiftUI
import Observation
import AppKit

@Observable
class ArrangeStore {
    // MARK: - State

    var windows: [WindowInfo] = []
    var screens: [ScreenInfo] = []
    var selectedScreenIndex: Int = 0
    var selectedPresetIndex: Int = 0
    var layoutState: LayoutState
    var modifyText: String = ""
    var statusText: String = ""
    var hasAccessibilityPermission: Bool = false
    var isLoading: Bool = false
    var panelSize: Theme.PanelSize {
        get { ThemeConfig.shared.panelSize }
        set { ThemeConfig.shared.panelSize = newValue }
    }
    var themeConfig = ThemeConfig.shared

    // Drag state
    var dragSource: (col: Int, app: Int)?
    var dropTarget: (col: Int, app: Int)?
    var isDragging: Bool = false
    var dragPosition: CGPoint?

    // Manual window-to-slot assignments (overrides auto-assignment after user swaps)
    var manualAssignments: [(col: Int, app: Int, window: WindowInfo?)]?

    // Exclusions
    var excludedWindowKeys: Set<String> = []

    // Saved layouts
    var savedLayouts: [SavedLayout] = []

    // Debug
    struct FrameDelta {
        let expected: CGRect
        let actual: CGRect
        var clamped: Bool {
            abs(actual.width - expected.width) > 1 || abs(actual.height - expected.height) > 1
        }
    }
    var frameDeltas: [String: FrameDelta] = [:]

    // Settings
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "claudeAPIKey") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "claudeAPIKey") }
    }

    // MARK: - Services

    let accessibilityService = AccessibilityService()
    let screenService = ScreenService()
    let layoutEngine = LayoutEngine()
    let windowMover = WindowMover()
    let claudeService = ClaudeService()

    // Available presets (regenerated when window count changes)
    var availablePresets: [LayoutPreset] = LayoutPreset.presets(forCount: 0)

    // MARK: - Init

    init() {
        let presets = LayoutPreset.presets(forCount: 0)
        availablePresets = presets
        layoutState = LayoutState(preset: presets[0])
        loadLayouts()
    }

    // MARK: - Computed

    var currentPreset: LayoutPreset {
        get { layoutState.preset }
        set { layoutState.preset = newValue }
    }

    var selectedScreen: ScreenInfo? {
        guard selectedScreenIndex < screens.count else { return nil }
        return screens[selectedScreenIndex]
    }

    var effectiveWindows: [WindowInfo] {
        windows.filter { !isExcluded($0) }
    }

    var effectivePreset: LayoutPreset {
        guard !excludedWindowKeys.isEmpty else { return currentPreset }
        let count = max(1, effectiveWindows.count)
        let options = LayoutPreset.presets(forCount: count)
        return options.first { $0.name == currentPreset.name } ?? options[0]
    }

    var assignments: [(col: Int, app: Int, window: WindowInfo?)] {
        if let manual = manualAssignments { return manual }
        return layoutEngine.assign(windows: effectiveWindows, to: effectivePreset)
    }

    func windowFor(col: Int, app: Int) -> WindowInfo? {
        assignments.first { $0.col == col && $0.app == app }?.window
    }

    func accentLevel(col: Int, app: Int) -> AccentLevel {
        layoutEngine.accentLevel(for: effectivePreset, col: col, app: app)
    }

    // MARK: - Refresh

    func refresh() {
        screens = screenService.detectScreens()
        if selectedScreenIndex >= screens.count {
            selectedScreenIndex = 0
        }
        if hasAccessibilityPermission {
            windows = accessibilityService.listWindows()
        }
        let validKeys = Set(windows.map { $0.stableKey })
        excludedWindowKeys = excludedWindowKeys.intersection(validKeys)
        regeneratePresets()

        screenService.observeChanges { [weak self] in
            self?.screens = self?.screenService.detectScreens() ?? []
        }
    }

    // MARK: - Exclusion

    func isExcluded(_ w: WindowInfo) -> Bool {
        excludedWindowKeys.contains(w.stableKey)
    }

    func toggleExclusion(for w: WindowInfo) {
        if excludedWindowKeys.contains(w.stableKey) {
            excludedWindowKeys.remove(w.stableKey)
        } else {
            excludedWindowKeys.insert(w.stableKey)
        }
    }

    // MARK: - Preset Selection

    func selectPreset(at index: Int) {
        guard index < availablePresets.count else { return }
        layoutState.pushUndo()
        selectedPresetIndex = index
        layoutState.preset = availablePresets[index]
        manualAssignments = nil
        statusText = currentPreset.name
    }

    func resetPreset() {
        guard selectedPresetIndex < availablePresets.count else { return }
        layoutState.reset(to: availablePresets[selectedPresetIndex])
        manualAssignments = nil
        statusText = "Reset to default"
    }

    // MARK: - Apply

    func apply() {
        guard let screen = selectedScreen else {
            statusText = "No screen selected"
            return
        }
        let frames = layoutEngine.resolveForScreen(preset: effectivePreset, screen: screen)
        let assigned = assignments
        windowMover.snapshot(windows: windows)
        frameDeltas = [:]

        var moved = 0
        for assignment in assigned {
            guard let window = assignment.window else { continue }
            guard !isExcluded(window) else { continue }
            if let resolved = frames.first(where: { $0.col == assignment.col && $0.app == assignment.app }) {
                accessibilityService.setFrame(for: window, frame: resolved.rect)
                moved += 1
            }
        }

        // Pass 2: Re-center windows that were clamped (e.g., terminal apps with character-grid snapping)
        for assignment in assigned {
            guard let window = assignment.window else { continue }
            guard !isExcluded(window) else { continue }
            guard let resolved = frames.first(where: { $0.col == assignment.col && $0.app == assignment.app }) else { continue }
            guard let actual = accessibilityService.getFrame(for: window) else { continue }

            let target = resolved.rect
            let delta = FrameDelta(expected: target, actual: actual)
            frameDeltas[window.stableKey] = delta

            if delta.clamped {
                let centeredOrigin = CGPoint(
                    x: target.midX - actual.width / 2,
                    y: target.midY - actual.height / 2
                )
                accessibilityService.setPosition(window.axWindow, point: centeredOrigin)
            }
        }

        statusText = "\(moved) windows arranged"
    }

    // MARK: - Undo

    func undo() {
        if windowMover.hasSnapshot {
            windowMover.restore(using: accessibilityService)
            statusText = "Windows restored"
        } else if layoutState.undo() {
            statusText = "Layout restored"
        } else {
            statusText = "Nothing to undo"
        }
    }

    // MARK: - Block Swap

    func swapBlocks(from: (col: Int, app: Int), to: (col: Int, app: Int)) {
        guard from.col != to.col || from.app != to.app else { return }

        // Materialize current assignments
        var current = assignments

        guard let fromIdx = current.firstIndex(where: { $0.col == from.col && $0.app == from.app }),
              let toIdx = current.firstIndex(where: { $0.col == to.col && $0.app == to.app })
        else { return }

        // Swap only the window references — grid layout stays the same
        let tempWindow = current[fromIdx].window
        current[fromIdx] = (col: current[fromIdx].col, app: current[fromIdx].app, window: current[toIdx].window)
        current[toIdx] = (col: current[toIdx].col, app: current[toIdx].app, window: tempWindow)

        manualAssignments = current
    }

    // MARK: - Seam Drag

    func adjustColumnFlex(leftCol: Int, delta: Double) {
        guard leftCol >= 0 && leftCol + 1 < currentPreset.columns.count else { return }
        var preset = currentPreset
        let combined = preset.columns[leftCol].flex + preset.columns[leftCol + 1].flex
        let minFlex = combined * 0.12

        let newLeft = max(minFlex, min(combined - minFlex, preset.columns[leftCol].flex + delta))
        let newRight = combined - newLeft

        preset.columns[leftCol].flex = newLeft
        preset.columns[leftCol + 1].flex = newRight
        currentPreset = preset
    }

    func adjustAppFlex(col: Int, aboveApp: Int, delta: Double) {
        guard col < currentPreset.columns.count,
              aboveApp >= 0 && aboveApp + 1 < currentPreset.columns[col].apps.count
        else { return }

        var preset = currentPreset
        let combined = preset.columns[col].apps[aboveApp].flex + preset.columns[col].apps[aboveApp + 1].flex
        let minFlex = combined * 0.15

        let newAbove = max(minFlex, min(combined - minFlex, preset.columns[col].apps[aboveApp].flex + delta))
        let newBelow = combined - newAbove

        preset.columns[col].apps[aboveApp].flex = newAbove
        preset.columns[col].apps[aboveApp + 1].flex = newBelow
        currentPreset = preset
    }

    func beginSeamDrag() {
        layoutState.pushUndo()
    }

    func endSeamDrag() {}

    // MARK: - Claude Modify

    func modifyWithClaude() {
        guard !modifyText.isEmpty else { return }
        guard !apiKey.isEmpty else {
            statusText = "Set API key in menu bar → Settings"
            return
        }
        isLoading = true
        statusText = "Asking Claude..."
        let instruction = modifyText
        modifyText = ""

        let assignmentContext = assignments.compactMap { a -> String? in
            guard let w = a.window else { return nil }
            return "Column \(a.col + 1), slot \(a.app + 1): \(w.appName)"
        }.joined(separator: "\n")

        Task {
            do {
                let modified = try await claudeService.modify(
                    preset: currentPreset,
                    instruction: instruction,
                    assignmentContext: assignmentContext,
                    apiKey: apiKey
                )
                await MainActor.run {
                    layoutState.pushUndo()
                    currentPreset = modified
                    isLoading = false
                    statusText = "Layout modified"
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    statusText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Saved Layouts

    func saveCurrentLayout(name: String) {
        let slots: [SavedLayout.Slot] = assignments.compactMap { a in
            guard let w = a.window else { return nil }
            return SavedLayout.Slot(col: a.col, app: a.app, bundleId: w.bundleId, appName: w.appName)
        }
        let layout = SavedLayout(name: name, preset: effectivePreset, slots: slots)
        savedLayouts.append(layout)
        persistLayouts()
        statusText = "Layout \"\(name)\" saved"
    }

    func deleteLayout(id: UUID) {
        savedLayouts.removeAll { $0.id == id }
        persistLayouts()
    }

    func triggerLayout(_ layout: SavedLayout) {
        let runningBundleIds = Set(windows.map { $0.bundleId })
        let needed = Set(layout.slots.map { $0.bundleId }).subtracting(runningBundleIds)

        for bundleId in needed {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                NSWorkspace.shared.openApplication(at: url, configuration: .init(), completionHandler: nil)
            }
        }

        let delay: TimeInterval = needed.isEmpty ? 0.2 : 3.0
        statusText = needed.isEmpty ? "Applying layout..." : "Launching \(needed.count) app(s)..."

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.refresh()
            self.applyLayoutAssignments(layout)
            self.apply()
        }
    }

    private func applyLayoutAssignments(_ layout: SavedLayout) {
        currentPreset = layout.preset
        var result: [(col: Int, app: Int, window: WindowInfo?)] = layoutEngine.assign(
            windows: effectiveWindows, to: layout.preset
        )
        var usedIds = Set<UUID>()
        for slot in layout.slots {
            guard let idx = result.firstIndex(where: { $0.col == slot.col && $0.app == slot.app }) else { continue }
            if let window = effectiveWindows.first(where: { $0.bundleId == slot.bundleId && !usedIds.contains($0.id) }) {
                result[idx] = (col: slot.col, app: slot.app, window: window)
                usedIds.insert(window.id)
            }
        }
        manualAssignments = result
    }

    private func persistLayouts() {
        if let data = try? JSONEncoder().encode(savedLayouts) {
            UserDefaults.standard.set(data, forKey: "savedLayouts")
        }
    }

    private func loadLayouts() {
        guard let data = UserDefaults.standard.data(forKey: "savedLayouts"),
              let layouts = try? JSONDecoder().decode([SavedLayout].self, from: data) else { return }
        savedLayouts = layouts
    }

    // MARK: - Private

    private func regeneratePresets() {
        let count = max(1, windows.count)
        availablePresets = LayoutPreset.presets(forCount: count)
        selectedPresetIndex = 0
        layoutState = LayoutState(preset: availablePresets[0])
        manualAssignments = nil
    }
}
