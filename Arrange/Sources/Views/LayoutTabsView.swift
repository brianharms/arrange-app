import SwiftUI

struct LayoutTabsView: View {
    @Bindable var store: ArrangeStore
    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 2 : 4) {
            ForEach(Array(store.availablePresets.enumerated()), id: \.element.id) { index, preset in
                LayoutTab(
                    name: preset.name,
                    isActive: index == store.selectedPresetIndex
                ) {
                    store.selectPreset(at: index)
                }
            }

            Spacer()

            Button(action: { store.resetPreset() }) {
                Text("Reset")
                    .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                    .tracking(0.5)
            }
            .buttonStyle(.plain)
            .padding(.vertical, isSm ? 5 : 7)
            .padding(.horizontal, isSm ? 8 : 12)
            .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusSm))
            .themedBorder(radius: Theme.radiusSm)
        }
        .padding(.bottom, isSm ? 8 : 14)
    }
}

// MARK: - Layout Tab

struct LayoutTab: View {
    let name: String
    let isActive: Bool
    let action: () -> Void
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(Theme.mainFont(isSm ? 10 : 11, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.text3)
                .padding(.vertical, isSm ? 5 : 7)
                .padding(.horizontal, isSm ? 8 : 14)
                .background(
                    isActive ? Theme.bgActive : Color.clear,
                    in: RoundedRectangle(cornerRadius: Theme.radiusSm)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusSm)
                        .stroke(isActive ? Theme.borderActive : Color.clear, style: Theme.borderStrokeStyle)
                )
        }
        .buttonStyle(.plain)
    }
}
