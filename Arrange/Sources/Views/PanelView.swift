import SwiftUI

struct PanelView: View {
    @Bindable var store: ArrangeStore
    var dismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            MonitorBar(store: store)

            HStack(spacing: 0) {
                // Sidebar
                VStack(alignment: .leading, spacing: 0) {
                    WindowListView(store: store)
                    ModifyInputView(store: store)
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

    var body: some View {
        HStack {
            Text(text)
                .font(Theme.monoFont(isSm ? 10 : 11))
                .foregroundStyle(Theme.text3)
                .lineLimit(1)
            Spacer()
        }
        .frame(minHeight: isSm ? 14 : 18)
        .padding(.top, isSm ? 8 : 16)
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
