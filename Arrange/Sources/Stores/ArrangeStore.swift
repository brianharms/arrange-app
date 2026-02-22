import Foundation
import SwiftUI
import Observation

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
    var seamDragSnapshot: LayoutPreset?

    // Manual window-to-slot assignments (overrides auto-assignment after user swaps)
    private var manualAssignments: [(col: Int, app: Int, window: WindowInfo?)]?

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

    var assignments: [(col: Int, app: Int, window: WindowInfo?)] {
        manualAssignments ?? layoutEngine.assign(windows: windows, to: currentPreset)
    }

    func windowFor(col: Int, app: Int) -> WindowInfo? {
        assignments.first { $0.col == col && $0.app == app }?.window
    }

    func accentLevel(col: Int, app: Int) -> AccentLevel {
        layoutEngine.accentLevel(for: currentPreset, col: col, app: app)
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
        regeneratePresets()

        screenService.observeChanges { [weak self] in
            self?.screens = self?.screenService.detectScreens() ?? []
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
        let frames = layoutEngine.resolveForScreen(preset: currentPreset, screen: screen)
        let assigned = assignments
        windowMover.snapshot(windows: windows)

        var moved = 0
        for assignment in assigned {
            guard let window = assignment.window else { continue }
            if let resolved = frames.first(where: { $0.col == assignment.col && $0.app == assignment.app }) {
                accessibilityService.setFrame(for: window, frame: resolved.rect)
                moved += 1
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
        guard let snapshot = seamDragSnapshot else { return }
        guard leftCol >= 0 && leftCol + 1 < snapshot.columns.count else { return }
        var preset = currentPreset
        let snapshotLeft = snapshot.columns[leftCol].flex
        let snapshotRight = snapshot.columns[leftCol + 1].flex
        let combined = snapshotLeft + snapshotRight
        let minFlex = combined * 0.12

        let newLeft = max(minFlex, min(combined - minFlex, snapshotLeft + delta))
        let newRight = combined - newLeft

        preset.columns[leftCol].flex = newLeft
        preset.columns[leftCol + 1].flex = newRight
        currentPreset = preset
    }

    func adjustAppFlex(col: Int, aboveApp: Int, delta: Double) {
        guard let snapshot = seamDragSnapshot else { return }
        guard col < snapshot.columns.count,
              aboveApp >= 0 && aboveApp + 1 < snapshot.columns[col].apps.count
        else { return }

        var preset = currentPreset
        let snapshotAbove = snapshot.columns[col].apps[aboveApp].flex
        let snapshotBelow = snapshot.columns[col].apps[aboveApp + 1].flex
        let combined = snapshotAbove + snapshotBelow
        let minFlex = combined * 0.15

        let newAbove = max(minFlex, min(combined - minFlex, snapshotAbove + delta))
        let newBelow = combined - newAbove

        preset.columns[col].apps[aboveApp].flex = newAbove
        preset.columns[col].apps[aboveApp + 1].flex = newBelow
        currentPreset = preset
    }

    func beginSeamDrag() {
        layoutState.pushUndo()
        seamDragSnapshot = currentPreset
    }

    func endSeamDrag() {
        seamDragSnapshot = nil
    }

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

        Task {
            do {
                let modified = try await claudeService.modify(
                    preset: currentPreset,
                    instruction: instruction,
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

    // MARK: - Private

    private func regeneratePresets() {
        let count = max(1, windows.count)
        availablePresets = LayoutPreset.presets(forCount: count)
        selectedPresetIndex = 0
        layoutState = LayoutState(preset: availablePresets[0])
        manualAssignments = nil
    }
}
