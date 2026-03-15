import Foundation

struct LayoutPreset: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    var columns: [Column]
    var alignRows: Bool

    struct Column: Codable, Equatable {
        var flex: Double
        var apps: [AppSlot]
    }

    struct AppSlot: Codable, Equatable {
        var id: String
        var flex: Double
    }

    var totalSlots: Int {
        columns.reduce(0) { $0 + $1.apps.count }
    }

    // MARK: - Dynamic Presets

    private static func slot(_ i: Int) -> AppSlot {
        AppSlot(id: "app-\(i)", flex: 1)
    }

    private static func slot(_ i: Int, flex: Double) -> AppSlot {
        AppSlot(id: "app-\(i)", flex: flex)
    }

    static func presets(forCount n: Int) -> [LayoutPreset] {
        switch n {
        case 0, 1:
            return [
                LayoutPreset(id: "single", name: "Single",
                    columns: [Column(flex: 1, apps: [slot(0)])],
                    alignRows: false),
            ]
        case 2:
            return [
                LayoutPreset(id: "halves", name: "Columns",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                    ], alignRows: false),
                LayoutPreset(id: "focus2", name: "Focus",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                    ], alignRows: false),
                LayoutPreset(id: "stack2", name: "Stack",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                    ], alignRows: false),
                randomPreset(forCount: 2),
            ]
        case 3:
            return [
                LayoutPreset(id: "thirds", name: "Columns",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "focus3", name: "Focus",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "sidebar3", name: "Sidebar",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 2, apps: [slot(2)]),
                    ], alignRows: false),
                randomPreset(forCount: 3),
            ]
        case 4:
            return [
                LayoutPreset(id: "grid4", name: "Grid 2×2",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                    ], alignRows: true),
                LayoutPreset(id: "focus4", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2), slot(3)]),
                    ], alignRows: false),
                LayoutPreset(id: "cols4", name: "Columns",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2)]),
                        Column(flex: 1, apps: [slot(3)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade4", name: "Cascade",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                    ], alignRows: false),
                randomPreset(forCount: 4),
            ]
        case 5:
            return [
                LayoutPreset(id: "cols5", name: "Columns",
                    columns: (0..<5).map { Column(flex: 1, apps: [slot($0)]) },
                    alignRows: false),
                LayoutPreset(id: "focus5", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4)]),
                    ], alignRows: true),
                LayoutPreset(id: "grid5", name: "Grid 3+2",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(3)]),
                        Column(flex: 1, apps: [slot(1), slot(4)]),
                        Column(flex: 1, apps: [slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade5", name: "Cascade",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4)]),
                    ], alignRows: false),
                randomPreset(forCount: 5),
            ]
        case 6:
            return [
                LayoutPreset(id: "cols6", name: "Columns",
                    columns: (0..<6).map { Column(flex: 1, apps: [slot($0)]) },
                    alignRows: false),
                LayoutPreset(id: "grid6", name: "Grid 3×2",
                    columns: [
                        Column(flex: 2, apps: [slot(0, flex: 1), slot(1, flex: 0.55)]),
                        Column(flex: 1.5, apps: [slot(2, flex: 1), slot(3, flex: 0.55)]),
                        Column(flex: 1, apps: [slot(4, flex: 1), slot(5, flex: 0.55)]),
                    ], alignRows: true),
                LayoutPreset(id: "focus6", name: "Focus",
                    columns: [
                        Column(flex: 3, apps: [slot(0)]),
                        Column(flex: 2, apps: [slot(1), slot(2), slot(3), slot(4), slot(5)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade6", name: "Cascade",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1, flex: 1.2), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4), slot(5)]),
                    ], alignRows: false),
                LayoutPreset(id: "trident6", name: "Trident",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                        Column(flex: 1, apps: [slot(4), slot(5)]),
                    ], alignRows: true),
                randomPreset(forCount: 6),
            ]
        default: // 7+
            return [
                LayoutPreset(id: "cols", name: "Columns",
                    columns: (0..<n).map { Column(flex: 1, apps: [slot($0)]) },
                    alignRows: false),
                LayoutPreset(id: "grid", name: "Grid",
                    columns: gridColumns(for: n),
                    alignRows: true),
                LayoutPreset(id: "focus", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: (1..<n).map { slot($0) }),
                    ], alignRows: false),
                LayoutPreset(id: "cockpit", name: "Cockpit",
                    columns: cockpitColumns(for: n),
                    alignRows: false),
                randomPreset(forCount: n),
            ]
        }
    }

    private static func randomPreset(forCount n: Int) -> LayoutPreset {
        guard n > 1 else {
            return LayoutPreset(id: "random", name: "Random",
                columns: [Column(flex: 1, apps: [slot(0)])], alignRows: false)
        }
        var rng = SystemRandomNumberGenerator()
        let minCols = n <= 2 ? 1 : 2
        let maxCols = min(n, 4)
        let numCols = Int.random(in: minCols...maxCols, using: &rng)

        var slotIdx = 0
        var remaining = n
        var columns: [Column] = []

        for c in 0..<numCols {
            let colsLeft = numCols - c
            let appsInCol: Int
            if c == numCols - 1 {
                appsInCol = remaining
            } else {
                let maxApps = max(1, remaining - (colsLeft - 1))
                appsInCol = maxApps > 1 ? Int.random(in: 1...maxApps, using: &rng) : 1
            }
            let flex = Double(Int.random(in: 6...20, using: &rng)) / 10.0
            var apps: [AppSlot] = []
            for _ in 0..<appsInCol {
                let appFlex = Double(Int.random(in: 7...15, using: &rng)) / 10.0
                apps.append(AppSlot(id: "app-\(slotIdx)", flex: appFlex))
                slotIdx += 1
                remaining -= 1
            }
            columns.append(Column(flex: flex, apps: apps))
        }
        return LayoutPreset(id: "random", name: "Random", columns: columns, alignRows: false)
    }

    private static func gridColumns(for n: Int) -> [Column] {
        let cols = n <= 4 ? 2 : (n <= 9 ? 3 : 4)
        let perCol = n / cols
        let extra = n % cols
        var columns: [Column] = []
        var idx = 0
        for c in 0..<cols {
            let count = perCol + (c < extra ? 1 : 0)
            let apps = (0..<count).map { _ -> AppSlot in
                let s = slot(idx)
                idx += 1
                return s
            }
            columns.append(Column(flex: 1, apps: apps))
        }
        return columns
    }

    private static func cockpitColumns(for n: Int) -> [Column] {
        let sideCount = (n - 1) / 2
        let rightCount = n - 1 - sideCount
        var idx = 0
        let leftApps = (0..<sideCount).map { _ -> AppSlot in
            let s = slot(idx); idx += 1; return s
        }
        let centerApp = [slot(idx)]; idx += 1
        let rightApps = (0..<rightCount).map { _ -> AppSlot in
            let s = slot(idx); idx += 1; return s
        }
        return [
            Column(flex: 0.8, apps: leftApps),
            Column(flex: 2.5, apps: centerApp),
            Column(flex: 0.8, apps: rightApps),
        ]
    }
}
