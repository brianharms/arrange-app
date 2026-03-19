import SwiftUI

struct CanvasView: View {
    @Bindable var store: ArrangeStore

    var body: some View {
        GeometryReader { geo in
            let preset = store.effectivePreset
            let blockFrames = Self.computeBlockFrames(canvasSize: geo.size, preset: preset)

            // Only render columns that have at least one assigned window
            let filledCols = filledColumns(for: preset)
            let totalColFlex = filledCols.reduce(0.0) { $0 + $1.column.flex }
            let totalVSeams = CGFloat(max(0, filledCols.count - 1)) * Theme.seamWidth
            let availableWidth = geo.size.width - totalVSeams

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(Array(filledCols.enumerated()), id: \.element.colIndex) { renderColIndex, entry in
                        let colWidth = totalColFlex > 0
                            ? availableWidth * CGFloat(entry.column.flex / totalColFlex)
                            : availableWidth

                        columnView(
                            column: entry.column,
                            colIndex: entry.colIndex,
                            totalHeight: geo.size.height,
                            blockPositions: blockFrames
                        )
                        .frame(width: colWidth)

                        if renderColIndex < filledCols.count - 1 {
                            SeamView(
                                orientation: .vertical,
                                store: store,
                                col: entry.colIndex,
                                app: 0,
                                totalSize: availableWidth,
                                totalFlex: totalColFlex
                            )
                            .zIndex(1)
                        }
                    }
                }

                // Floating ghost block follows cursor during drag
                if store.isDragging,
                   let pos = store.dragPosition,
                   let source = store.dragSource,
                   let sourceBlock = blockFrames.first(where: { $0.col == source.col && $0.app == source.app }) {
                    DragGhostView(store: store, col: source.col, app: source.app)
                        .frame(width: sourceBlock.frame.width * 0.85, height: sourceBlock.frame.height * 0.85)
                        .position(x: pos.x, y: pos.y)
                        .allowsHitTesting(false)
                }
            }
        }
        .coordinateSpace(name: "canvas")
        .padding(Theme.canvasPadding)
        .frame(maxHeight: .infinity)
        .background(Theme.bgCanvas, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
        .themedBorder(radius: Theme.radiusMd)
        .overlay {
            if Theme.isASCII {
                ScanlineOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    .allowsHitTesting(false)
            } else if Theme.isCyber {
                DotGridOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    .allowsHitTesting(false)
            }
        }
    }

    // Returns only columns that have at least one window assigned
    private func filledColumns(for preset: LayoutPreset) -> [(colIndex: Int, column: LayoutPreset.Column)] {
        preset.columns.enumerated().compactMap { colIndex, col in
            let hasFilled = col.apps.indices.contains { appIndex in
                store.windowFor(col: colIndex, app: appIndex) != nil
            }
            return hasFilled ? (colIndex: colIndex, column: col) : nil
        }
    }

    // Returns only slots in a column that have a window assigned
    private func filledSlots(in column: LayoutPreset.Column, colIndex: Int) -> [(appIndex: Int, app: LayoutPreset.AppSlot)] {
        column.apps.indices.compactMap { appIndex in
            guard store.windowFor(col: colIndex, app: appIndex) != nil else { return nil }
            return (appIndex: appIndex, app: column.apps[appIndex])
        }
    }

    @ViewBuilder
    private func columnView(column: LayoutPreset.Column, colIndex: Int, totalHeight: CGFloat, blockPositions: [BlockPosition]) -> some View {
        let slots = filledSlots(in: column, colIndex: colIndex)
        let totalAppFlex = slots.reduce(0.0) { $0 + $1.app.flex }
        let totalHSeams = CGFloat(max(0, slots.count - 1)) * Theme.seamWidth
        let availableHeight = totalHeight - totalHSeams

        VStack(spacing: 0) {
            ForEach(Array(slots.enumerated()), id: \.element.appIndex) { renderAppIndex, slot in
                let appHeight = totalAppFlex > 0
                    ? availableHeight * CGFloat(slot.app.flex / totalAppFlex)
                    : availableHeight

                AppBlockView(
                    store: store,
                    col: colIndex,
                    app: slot.appIndex,
                    blockPositions: blockPositions
                )
                .frame(height: appHeight)

                if renderAppIndex < slots.count - 1 {
                    SeamView(
                        orientation: .horizontal,
                        store: store,
                        col: colIndex,
                        app: slot.appIndex,
                        totalSize: availableHeight,
                        totalFlex: totalAppFlex
                    )
                    .zIndex(1)
                }
            }
        }
    }

    // Compute block frames from the full preset (used for drag hit-testing)
    static func computeBlockFrames(canvasSize: CGSize, preset: LayoutPreset) -> [BlockPosition] {
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * Theme.seamWidth
        let availableWidth = canvasSize.width - totalVSeams

        var positions: [BlockPosition] = []
        var xOffset: CGFloat = 0

        for (colIndex, column) in preset.columns.enumerated() {
            let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * Theme.seamWidth
            let availableHeight = canvasSize.height - totalHSeams

            var yOffset: CGFloat = 0

            for (appIndex, app) in column.apps.enumerated() {
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)
                positions.append(BlockPosition(
                    col: colIndex,
                    app: appIndex,
                    frame: CGRect(x: xOffset, y: yOffset, width: colWidth, height: appHeight)
                ))
                yOffset += appHeight + Theme.seamWidth
            }

            xOffset += colWidth + Theme.seamWidth
        }

        return positions
    }
}
