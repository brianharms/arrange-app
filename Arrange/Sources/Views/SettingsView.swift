import SwiftUI

struct SettingsView: View {
    @Bindable var store: ArrangeStore
    @State private var keyText: String = ""
    @AppStorage("debugMode") private var debugMode = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Claude API Key")
                .font(.headline)

            SecureField("sk-ant-...", text: $keyText)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 0) {
                Text("Used for natural language layout modification. Get a key at ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: {
                    if let url = URL(string: "https://console.anthropic.com/settings/keys") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("console.anthropic.com")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                Text(".")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button("Save") {
                    store.apiKey = keyText
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            Text("Accessibility Permission")
                .font(.headline)

            HStack(spacing: 12) {
                Circle()
                    .fill(store.hasAccessibilityPermission ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(store.hasAccessibilityPermission ? "Granted" : "Not granted")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            Text("If Arrange already appears as approved but isn't working, select it in the list, press the minus (−) button to remove it, enter your password if prompted, then press the plus (+) button and re-add Arrange from your Applications folder.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Text("Debug")
                .font(.headline)

            Toggle("Show size diagnostics after Apply", isOn: $debugMode)
                .toggleStyle(.switch)

            Text("After applying a layout, each block shows expected vs. actual window size. Useful for diagnosing terminal app sizing issues.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            keyText = store.apiKey
        }
    }
}
