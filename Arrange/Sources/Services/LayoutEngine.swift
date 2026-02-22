import AppKit
import SwiftUI

struct ResolvedRect {
    let col: Int
    let app: Int
    let rect: CGRect
}

struct SlotArea: Comparable {
    let col: Int
    let app: Int
    let area: Double

    static func < (lhs: SlotArea, rhs: SlotArea) -> Bool {
        lhs.area < rhs.area
    }
}

enum AccentLevel {
    case primary
    case secondary
    case none
}

class LayoutEngine {

    // MARK: - Resolve Flex → CGRect

    /// Resolves preset flex values into actual pixel rects within given bounds.
    /// Bounds should be in the target coordinate system (AX coords for window moving,
    /// or local coords for canvas preview).
    func resolve(preset: LayoutPreset, in bounds: CGRect) -> [ResolvedRect] {
        let seamW = Theme.seamWidth
        let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * seamW
        let availableWidth = bounds.width - totalVSeams
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }

        var results: [ResolvedRect] = []
        var x = bounds.minX

        for (colIndex, column) in preset.columns.enumerated() {
            let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)
            let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * seamW
            let availableHeight = bounds.height - totalHSeams
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }

            var y = bounds.minY

            for (appIndex, app) in column.apps.enumerated() {
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)
                let rect = CGRect(x: x, y: y, width: colWidth, height: appHeight)
                results.append(ResolvedRect(col: colIndex, app: appIndex, rect: rect))
                y += appHeight + seamW
            }

            x += colWidth + seamW
        }

        return results
    }

    // MARK: - Window Assignment

    /// Assigns windows to preset slots by area heuristic (largest window → largest slot).
    /// Returns an array of (col, app, window?) tuples for every slot.
    func assign(windows: [WindowInfo], to preset: LayoutPreset) -> [(col: Int, app: Int, window: WindowInfo?)] {
        // Calculate proportional area for each slot
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        var slotAreas: [SlotArea] = []

        for (colIndex, column) in preset.columns.enumerated() {
            let colProportion = column.flex / totalColFlex
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            for (appIndex, app) in column.apps.enumerated() {
                let appProportion = app.flex / totalAppFlex
                let area = colProportion * appProportion
                slotAreas.append(SlotArea(col: colIndex, app: appIndex, area: area))
            }
        }

        // Sort slots by area descending
        let sortedSlots = slotAreas.sorted { $0.area > $1.area }

        // Sort windows by current area descending
        let sortedWindows = windows.sorted { $0.area > $1.area }

        // Match 1:1
        var assignments: [String: WindowInfo] = [:]  // "col-app" → window
        for (i, slot) in sortedSlots.enumerated() {
            if i < sortedWindows.count {
                assignments["\(slot.col)-\(slot.app)"] = sortedWindows[i]
            }
        }

        // Build result array in slot order
        var result: [(col: Int, app: Int, window: WindowInfo?)] = []
        for (colIndex, column) in preset.columns.enumerated() {
            for appIndex in 0..<column.apps.count {
                let key = "\(colIndex)-\(appIndex)"
                result.append((col: colIndex, app: appIndex, window: assignments[key]))
            }
        }

        return result
    }

    // MARK: - Accent Calculation

    func accentLevel(for preset: LayoutPreset, col: Int, app: Int) -> AccentLevel {
        let areas = slotAreas(for: preset)
        let sorted = areas.sorted { $0.area > $1.area }

        guard sorted.count >= 2 else {
            if sorted.count == 1 && sorted[0].col == col && sorted[0].app == app {
                return .primary
            }
            return .none
        }

        if sorted[0].col == col && sorted[0].app == app { return .primary }
        if sorted[1].col == col && sorted[1].app == app { return .secondary }
        return .none
    }

    func slotAreas(for preset: LayoutPreset) -> [SlotArea] {
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        var areas: [SlotArea] = []

        for (colIndex, column) in preset.columns.enumerated() {
            let colProportion = column.flex / totalColFlex
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            for (appIndex, app) in column.apps.enumerated() {
                let appProportion = app.flex / totalAppFlex
                areas.append(SlotArea(
                    col: colIndex, app: appIndex,
                    area: colProportion * appProportion
                ))
            }
        }

        return areas
    }

    // MARK: - Screen Coordinate Resolution

    /// Resolves preset for actual screen placement. Converts NSScreen visibleFrame to AX coords.
    func resolveForScreen(preset: LayoutPreset, screen: ScreenInfo) -> [ResolvedRect] {
        guard let primary = NSScreen.screens.first else { return [] }
        let h = primary.frame.height
        let vis = screen.visibleFrame

        // Convert NSScreen visibleFrame to AX coordinates (top-left origin)
        let axBounds = CGRect(
            x: vis.origin.x,
            y: h - vis.origin.y - vis.height,
            width: vis.width,
            height: vis.height
        )

        return resolve(preset: preset, in: axBounds)
    }
}
