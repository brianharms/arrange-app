import SwiftUI

enum SeamOrientation {
    case vertical
    case horizontal
}

struct SeamView: View {
    let orientation: SeamOrientation
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int
    let totalSize: CGFloat
    let totalFlex: Double

    @State private var isHovered = false
    @State private var isActive = false
    @State private var lastTranslation: CGFloat = 0

    var body: some View {
        Group {
            switch orientation {
            case .vertical:
                verticalSeam
            case .horizontal:
                horizontalSeam
            }
        }
    }

    // MARK: - Vertical Seam

    private var verticalSeam: some View {
        Color.white.opacity(0.001)
            .frame(width: Theme.seamWidth)
            .contentShape(Rectangle())
            .overlay {
                RoundedRectangle(cornerRadius: 1)
                    .fill(isHovered || isActive ? Theme.accent : Theme.text5)
                    .frame(width: 2, height: 36)
            }
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .named("canvas"))
                    .onChanged { value in
                        if !isActive {
                            isActive = true
                            lastTranslation = 0
                            store.beginSeamDrag()
                        }
                        let current = value.translation.width
                        let frameDelta = current - lastTranslation
                        lastTranslation = current
                        let pixelsPerFlex = totalSize / CGFloat(totalFlex)
                        let flexDelta = Double(frameDelta) / Double(pixelsPerFlex)
                        store.adjustColumnFlex(leftCol: col, delta: flexDelta)
                    }
                    .onEnded { _ in
                        isActive = false
                        lastTranslation = 0
                        store.endSeamDrag()
                    }
            )
    }

    // MARK: - Horizontal Seam

    private var horizontalSeam: some View {
        Color.white.opacity(0.001)
            .frame(height: Theme.seamWidth)
            .contentShape(Rectangle())
            .overlay {
                RoundedRectangle(cornerRadius: 1)
                    .fill(isHovered || isActive ? Theme.accent : Theme.text5)
                    .frame(width: 36, height: 2)
            }
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .named("canvas"))
                    .onChanged { value in
                        if !isActive {
                            isActive = true
                            lastTranslation = 0
                            store.beginSeamDrag()
                        }
                        let current = value.translation.height
                        let frameDelta = current - lastTranslation
                        lastTranslation = current
                        let pixelsPerFlex = totalSize / CGFloat(totalFlex)
                        let flexDelta = Double(frameDelta) / Double(pixelsPerFlex)
                        store.adjustAppFlex(col: col, aboveApp: app, delta: flexDelta)
                    }
                    .onEnded { _ in
                        isActive = false
                        lastTranslation = 0
                        store.endSeamDrag()
                    }
            )
    }
}
