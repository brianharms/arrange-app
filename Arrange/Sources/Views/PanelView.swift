import SwiftUI
import AppKit

struct PanelView: View {
    @Bindable var store: ArrangeStore
    var dismiss: () -> Void
    var minimize: () -> Void = {}
    var zoom: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            TopBar(dismiss: dismiss, minimize: minimize, zoom: zoom)
            MonitorBar(store: store)

            HStack(spacing: 0) {
                // Sidebar
                VStack(alignment: .leading, spacing: 0) {
                    WindowListView(store: store)
                    Rectangle()
                        .fill(Theme.border)
                        .frame(height: 1)
                        .padding(.bottom, store.panelSize == .sm ? 8 : 12)
                    SavedLayoutsView(store: store)
                    ActionButtons(store: store)
                }
                .frame(width: store.panelSize.sidebarWidth)
                .padding(store.panelSize.padding)

                // Divider
                Rectangle()
                    .fill(Theme.border)
                    .frame(width: 1)
                    .if(Theme.isASCII) { $0.overlay(
                        Rectangle()
                            .stroke(Theme.border, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .frame(width: 1)
                    )}

                // Main area
                VStack(spacing: 0) {
                    LayoutTabsView(store: store)
                    CanvasView(store: store)
                    StatusLine(text: store.statusText)
                }
                .padding(store.panelSize.padding)
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
            .background(NonMovableBackground())
        }
        .frame(width: store.panelSize.dimensions.width, height: store.panelSize.dimensions.height)
        .animation(.easeInOut(duration: 0.25), value: store.panelSize)
        .background(Theme.bgPanel)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
        .themedBorder(radius: Theme.radiusLg)
        .shadow(
            color: Theme.panelShadow.color,
            radius: Theme.panelShadow.radius,
            x: Theme.panelShadow.x,
            y: Theme.panelShadow.y
        )
    }
}

// MARK: - Status Line

struct StatusLine: View {
    let text: String
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }
    @State private var ritualHovered = false

    var body: some View {
        HStack {
            Text(text)
                .font(Theme.monoFont(isSm ? 10 : 11))
                .foregroundStyle(Theme.text3)
                .lineLimit(1)
            Spacer()
            HStack(spacing: 0) {
                Text("powered by ")
                    .font(Theme.monoFont(isSm ? 9 : 10))
                    .foregroundStyle(Theme.text4)
                Button(action: {
                    if let url = URL(string: "https://ritual.industries") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("ritual.industries")
                        .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
                        .foregroundStyle(ritualHovered ? Color.red : Theme.text3)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    ritualHovered = hovering
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
            .padding(.trailing, 5)
        }
        .frame(minHeight: isSm ? 14 : 18)
        .padding(.top, isSm ? 8 : 16)
    }
}

// MARK: - Non-Movable Background
// Prevents isMovableByWindowBackground from stealing drag gestures in the content area

private struct NonMovableBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { _NonMovableView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    private class _NonMovableView: NSView {
        override var mouseDownCanMoveWindow: Bool { false }
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
