import SwiftUI

struct MonitorBar: View {
    @Bindable var store: ArrangeStore

    private var monitorLabel: String {
        Theme.isASCII ? "> DISPLAY" : "DISPLAY"
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(monitorLabel)
                .font(Theme.monoFont(10, weight: .semibold))
                .foregroundStyle(Theme.text3)
                .tracking(Theme.isCyber ? 2 : 1.5)
                .padding(.trailing, 8)

            ForEach(Array(store.screens.enumerated()), id: \.element.id) { index, screen in
                MonitorTab(
                    name: screen.name,
                    resolution: screen.resolution,
                    isActive: index == store.selectedScreenIndex
                ) {
                    store.selectedScreenIndex = index
                }
            }

            if store.screens.isEmpty {
                Text("No displays detected")
                    .font(Theme.monoFont(10))
                    .foregroundStyle(Theme.text4)
            }

            Spacer()

            HStack(spacing: 2) {
                ForEach(Theme.PanelSize.allCases, id: \.self) { size in
                    Button(action: { store.panelSize = size }) {
                        Text(size.rawValue.uppercased())
                            .font(Theme.monoFont(9, weight: .semibold))
                            .foregroundStyle(store.panelSize == size ? Theme.text1 : Theme.text4)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(
                                store.panelSize == size ? Theme.bgActive : Color.clear,
                                in: RoundedRectangle(cornerRadius: 4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, store.panelSize == .sm ? 8 : 12)
        .padding(.horizontal, store.panelSize == .sm ? 16 : 24)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Monitor Tab

struct MonitorTab: View {
    let name: String
    let resolution: String
    let isActive: Bool
    let action: () -> Void

    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Theme.accent : Theme.text5)
                    .frame(width: 6, height: 6)

                Text(name)
                    .font(Theme.mainFont(isSm ? 11 : 12, weight: .semibold))
                    .foregroundStyle(isActive ? Theme.text1 : Theme.text3)
                    .lineLimit(1)

                if !isSm {
                    Text(resolution)
                        .font(Theme.monoFont(9))
                        .foregroundStyle(Theme.text4)
                }
            }
            .padding(.vertical, isSm ? 6 : 8)
            .padding(.horizontal, isSm ? 10 : 16)
            .background(
                isActive ? Theme.bgActive : Color.clear,
                in: RoundedRectangle(cornerRadius: Theme.radiusSm)
            )
        }
        .buttonStyle(.plain)
    }
}
