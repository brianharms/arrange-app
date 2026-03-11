import SwiftUI

struct AppBlockView: View {
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int
    let blockPositions: [BlockPosition]

    @State private var justSwapped = false
    @State private var isHovered = false
    @AppStorage("debugMode") private var debugMode = false

    private var window: WindowInfo? {
        store.windowFor(col: col, app: app)
    }

    private var isWindowExcluded: Bool {
        guard let w = window else { return false }
        return store.isExcluded(w)
    }

    private var frameDelta: ArrangeStore.FrameDelta? {
        guard let w = window else { return nil }
        return store.frameDeltas[w.stableKey]
    }

    private var accent: AccentLevel {
        store.accentLevel(col: col, app: app)
    }

    private var bgColor: Color {
        if let w = window { return Theme.appColor(for: w.bundleId).bg }
        return Theme.bgSurface
    }

    private var textColor: Color {
        if let w = window { return Theme.appColor(for: w.bundleId).text }
        return Theme.text4
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
        Theme.isGrey || Theme.isBW
    }

    private var abbreviation: String {
        let name = window?.displayName ?? "Empty"
        // Use first letter of each word, or first 2 chars if single word
        let words = name.split(separator: " ")
        if words.count >= 2 {
            let abbr = words.prefix(3).map { String($0.prefix(1)) }.joined()
            return Theme.isASCII || Theme.isCyber ? abbr.uppercased() : abbr
        }
        let abbr = String(name.prefix(2))
        return Theme.isASCII || Theme.isCyber ? abbr.uppercased() : abbr
    }

    private func nameTracking() -> CGFloat {
        Theme.isASCII ? 2 : (Theme.isCyber ? 3 : 0)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(bgColor)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let isNarrow = w < 80
                let isVeryNarrow = w < 45
                let isTall = h > 50

                let nameSize: CGFloat = isVeryNarrow ? 9 : (isNarrow ? 10 : (Theme.isASCII ? 11 : 12))
                let nameLines = (isNarrow && isTall && !isVeryNarrow) ? 2 : 1
                let showSubtitle = !isNarrow
                let showAbbreviation = isVeryNarrow

                VStack(spacing: 2) {
                    Text(showAbbreviation ? abbreviation : displayName)
                        .font(Theme.mainFont(nameSize, weight: .semibold))
                        .foregroundStyle(textColor)
                        .tracking(nameTracking())
                        .lineLimit(nameLines)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                    if showSubtitle, let win = window, let sub = store.displaySubtitle(for: win) {
                        Text(sub)
                            .font(Theme.monoFont(9))
                            .foregroundStyle(textColor.opacity(0.6))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .padding(.horizontal, isVeryNarrow ? 3 : 8)
                .frame(width: w, height: h)
            }
        }
        .saturation(shouldDesaturate ? 0 : 1)
        .contrast(shouldDesaturate && Theme.isBW ? 1.4 : 1)
        .opacity(store.isDragging && store.dragSource?.col == col && store.dragSource?.app == app ? 0.25 : 1)
        .overlay(alignment: .topTrailing) {
            if isHovered, let w = window {
                Button {
                    store.toggleExclusion(for: w)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(textColor.opacity(0.8))
                        .frame(width: 18, height: 18)
                        .background(bgColor.opacity(0.85))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(textColor.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(5)
                .transition(.opacity)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if debugMode, let delta = frameDelta {
                DebugBadge(delta: delta)
            }
        }
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
        .gesture(dragGesture)
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

// MARK: - Debug Badge

struct DebugBadge: View {
    let delta: ArrangeStore.FrameDelta

    var body: some View {
        Group {
            if delta.clamped {
                Text("exp \(Int(delta.expected.width))×\(Int(delta.expected.height)) → got \(Int(delta.actual.width))×\(Int(delta.actual.height))")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.yellow.opacity(0.85))
                    .clipShape(Capsule())
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.green)
                    .padding(4)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.bottom, 4)
        .padding(.trailing, 5)
    }
}

// MARK: - Block Position

struct BlockPosition: Equatable {
    let col: Int
    let app: Int
    let frame: CGRect
}
