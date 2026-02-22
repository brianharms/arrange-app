import SwiftUI

struct AppBlockView: View {
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int
    let blockPositions: [BlockPosition]

    @State private var justSwapped = false
    @State private var isHovered = false

    private var window: WindowInfo? {
        store.windowFor(col: col, app: app)
    }

    private var accent: AccentLevel {
        store.accentLevel(col: col, app: app)
    }

    private var bgColor: Color {
        switch accent {
        case .primary:   return Theme.accent
        case .secondary: return Theme.accentDark
        case .none:
            if let w = window {
                return Theme.appColor(for: w.bundleId).bg
            }
            return Theme.bgSurface
        }
    }

    private var textColor: Color {
        switch accent {
        case .primary, .secondary: return .white
        case .none:
            if let w = window {
                return Theme.appColor(for: w.bundleId).text
            }
            return Theme.text4
        }
    }

    private var displayName: String {
        let name = window?.displayName ?? "Empty"
        if Theme.isASCII || Theme.isCyber { return name.uppercased() }
        return name
    }

    private var isDropTarget: Bool {
        store.dropTarget?.col == col && store.dropTarget?.app == app
    }

    private var shouldDesaturate: Bool {
        accent == .none && (Theme.isGrey || Theme.isBW)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(bgColor)

            Text(displayName)
                .font(Theme.mainFont(Theme.isASCII ? 11 : 12, weight: .semibold))
                .foregroundStyle(textColor)
                .tracking(Theme.isASCII ? 2 : (Theme.isCyber ? 3 : 0))
                .lineLimit(1)
        }
        .saturation(shouldDesaturate ? 0 : 1)
        .contrast(shouldDesaturate && Theme.isBW ? 1.4 : 1)
        .opacity(store.isDragging && store.dragSource?.col == col && store.dragSource?.app == app ? 0.25 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(isDropTarget ? Theme.accent : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isDropTarget ? Theme.accent.opacity(0.3) : .clear,
            radius: isDropTarget ? 10 : 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(justSwapped ? Theme.accent : Color.clear, lineWidth: 2)
                .shadow(color: justSwapped ? Theme.accent.opacity(0.5) : .clear, radius: 12)
        )
        .overlay {
            if Theme.isCyber {
                CyberBracketOverlay(opacity: isHovered ? 0.8 : 0.35)
            }
        }
        .if(Theme.isASCII) { $0.themedBorder(radius: Theme.radiusMd, color: Theme.borderActive) }
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .highPriorityGesture(dragGesture)
    }

    // MARK: - Drag Gesture

    private var sourceFrame: CGRect? {
        blockPositions.first(where: { $0.col == col && $0.app == app })?.frame
    }

    private func canvasPoint(from value: DragGesture.Value) -> CGPoint? {
        guard let origin = sourceFrame?.origin else { return nil }
        return CGPoint(
            x: origin.x + value.location.x,
            y: origin.y + value.location.y
        )
    }

    private func hitTest(_ point: CGPoint) -> (col: Int, app: Int)? {
        for pos in blockPositions {
            if pos.frame.contains(point) && (pos.col != col || pos.app != app) {
                return (col: pos.col, app: pos.app)
            }
        }
        return nil
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if !store.isDragging {
                    store.isDragging = true
                    store.dragSource = (col: col, app: app)
                }
                guard let point = canvasPoint(from: value) else { return }
                store.dragPosition = point
                store.dropTarget = hitTest(point)
            }
            .onEnded { value in
                // Compute drop target from final position directly
                let target: (col: Int, app: Int)?
                if let point = canvasPoint(from: value) {
                    target = hitTest(point)
                } else {
                    target = store.dropTarget
                }

                if let source = store.dragSource, let target = target {
                    store.swapBlocks(from: source, to: target)
                    justSwapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        justSwapped = false
                    }
                }
                store.isDragging = false
                store.dragSource = nil
                store.dropTarget = nil
                store.dragPosition = nil
            }
    }
}

// MARK: - Drag Ghost

struct DragGhostView: View {
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int

    private var window: WindowInfo? {
        store.windowFor(col: col, app: app)
    }

    private var bgColor: Color {
        if let w = window {
            return Theme.appColor(for: w.bundleId).bg
        }
        return Theme.bgSurface
    }

    private var displayName: String {
        window?.displayName ?? "Empty"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(bgColor)
            Text(displayName)
                .font(Theme.mainFont(11, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .opacity(0.85)
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }
}

// MARK: - Block Position

struct BlockPosition: Equatable {
    let col: Int
    let app: Int
    let frame: CGRect
}
