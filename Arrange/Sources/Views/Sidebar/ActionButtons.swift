import SwiftUI

struct ActionButtons: View {
    @Bindable var store: ArrangeStore
    @State private var showAI = false

    private var isSm: Bool { store.panelSize == .sm }
    private var hasKey: Bool { !store.apiKey.isEmpty }

    var body: some View {
        VStack(spacing: isSm ? 6 : 8) {
            HStack(spacing: isSm ? 6 : 8) {
                // AI toggle button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) { showAI.toggle() }
                }) {
                    Text("AI")
                        .font(Theme.mainFont(isSm ? 10 : 11, weight: .bold))
                        .foregroundStyle(showAI ? Theme.accent : Theme.text2)
                        .padding(.vertical, isSm ? 8 : 12)
                        .padding(.horizontal, isSm ? 10 : 14)
                        .background(
                            showAI ? Theme.accent.opacity(0.15) : Theme.bgSurface,
                            in: RoundedRectangle(cornerRadius: Theme.radiusMd)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMd)
                                .stroke(showAI ? Theme.accent.opacity(0.5) : Theme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                // Undo button
                Button(action: { store.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: isSm ? 10 : 11, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                        .padding(.vertical, isSm ? 8 : 12)
                        .padding(.horizontal, isSm ? 10 : 14)
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

            if showAI {
                if hasKey {
                    TextField("", text: $store.modifyText, prompt: Text("e.g. make VS Code larger").foregroundColor(Theme.text3))
                        .textFieldStyle(.plain)
                        .font(Theme.mainFont(isSm ? 11 : 13))
                        .foregroundStyle(Theme.text1)
                        .padding(.vertical, isSm ? 9 : 13)
                        .padding(.horizontal, isSm ? 10 : 14)
                        .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
                        .themedBorder(radius: Theme.radiusMd, color: Theme.inputBorder)
                        .onSubmit { store.modifyWithClaude() }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    VStack(alignment: .leading, spacing: isSm ? 3 : 4) {
                        Text("API key required.")
                            .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
                            .foregroundStyle(Theme.text2)
                        HStack(spacing: 0) {
                            Text("Get yours at ")
                                .font(Theme.monoFont(isSm ? 9 : 10))
                                .foregroundStyle(Theme.text3)
                            Button(action: {
                                if let url = URL(string: "https://console.anthropic.com/settings/keys") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("console.anthropic.com")
                                    .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
                                    .foregroundStyle(Theme.accent)
                            }
                            .buttonStyle(.plain)
                            .onHover { if $0 { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
                        }
                        Text("Paste it in Settings (gear icon).")
                            .font(Theme.monoFont(isSm ? 9 : 10))
                            .foregroundStyle(Theme.text4)
                    }
                    .padding(.vertical, isSm ? 8 : 10)
                    .padding(.horizontal, isSm ? 10 : 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
                    .themedBorder(radius: Theme.radiusMd)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
