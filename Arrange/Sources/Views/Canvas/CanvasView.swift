import SwiftUI

struct CanvasView: View {
    @Bindable var store: ArrangeStore

    var body: some View {
        GeometryReader { geo in
            let preset = store.currentPreset
            let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
            let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * Theme.seamWidth
            let availableWidth = geo.size.width - totalVSeams
            let blockFrames = Self.computeBlockFrames(canvasSize: geo.size, preset: preset)

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(Array(preset.columns.enumerated()), id: \.offset) { colIndex, column in
                        let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)

                        columnView(
                            column: column,
                            colIndex: colIndex,
                            totalHeight: geo.size.height,
                            blockPositions: blockFrames
                        )
                        .frame(width: colWidth)

                        // Vertical seam between columns
                        if colIndex < preset.columns.count - 1 {
                            SeamView(
                                orientation: .vertical,
                                store: store,
                                col: colIndex,
                                app: 0,
                                totalSize: availableWidth,
                                totalFlex: totalColFlex
                            )
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

    @ViewBuilder
    private func columnView(column: LayoutPreset.Column, colIndex: Int, totalHeight: CGFloat, blockPositions: [BlockPosition]) -> some View {
        let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
        let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * Theme.seamWidth
        let availableHeight = totalHeight - totalHSeams

        VStack(spacing: 0) {
            ForEach(Array(column.apps.enumerated()), id: \.offset) { appIndex, app in
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)

                AppBlockView(
                    store: store,
                    col: colIndex,
                    app: appIndex,
                    blockPositions: blockPositions
                )
                .frame(height: appHeight)

                // Horizontal seam between apps
                if appIndex < column.apps.count - 1 {
                    SeamView(
                        orientation: .horizontal,
                        store: store,
                        col: colIndex,
                        app: appIndex,
                        totalSize: availableHeight,
                        totalFlex: totalAppFlex
                    )
                }
            }
        }
    }

    // Compute block frames mathematically from flex values instead of using preferences
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
