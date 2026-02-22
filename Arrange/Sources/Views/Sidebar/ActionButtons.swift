import SwiftUI

struct ActionButtons: View {
    @Bindable var store: ArrangeStore

    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 6 : 8) {
            // Undo button
            Button(action: { store.undo() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: isSm ? 10 : 11, weight: .semibold))
                    Text("Undo")
                        .font(Theme.mainFont(isSm ? 11 : 12, weight: .semibold))
                }
                .foregroundStyle(Theme.text2)
                .padding(.vertical, isSm ? 8 : 12)
                .padding(.horizontal, isSm ? 12 : 18)
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
                .themedBorder(radius: Theme.radiusMd)
            }
            .buttonStyle(.plain)

            // Apply button
            Button(action: { store.apply() }) {
                HStack(spacing: 4) {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text(store.isLoading ? "Working..." : "Apply")
                        .font(Theme.mainFont(isSm ? 11 : 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isSm ? 8 : 12)
                .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
            }
            .buttonStyle(.plain)
            .disabled(store.isLoading)
        }
    }
}
