import SwiftUI

struct WindowListView: View {
    @Bindable var store: ArrangeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionLabel("WINDOWS IN LAYOUT")
                Spacer()
                Button(action: { store.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }

            ScrollView {
                VStack(spacing: 2) {
                    // Look up col/app for accent level on included windows
                    let assignmentMap = Dictionary(
                        store.assignments.compactMap { a -> (String, (col: Int, app: Int))? in
                            guard let w = a.window else { return nil }
                            return (w.stableKey, (col: a.col, app: a.app))
                        },
                        uniquingKeysWith: { first, _ in first }
                    )
                    ForEach(Array(store.windows.enumerated()), id: \.offset) { _, window in
                        let slot = assignmentMap[window.stableKey]
                        WindowRow(
                            name: window.displayName,
                            subtitle: window.subtitle,
                            accentLevel: slot.map { store.accentLevel(col: $0.col, app: $0.app) } ?? .none,
                            bundleId: window.bundleId,
                            isExcluded: store.isExcluded(window),
                            onToggle: { store.toggleExclusion(for: window) }
                        )
                    }

                    if store.windows.isEmpty && !store.hasAccessibilityPermission {
                        Text("Grant accessibility permission to detect windows")
                            .font(Theme.monoFont(10))
                            .foregroundStyle(Theme.text4)
                            .padding(.vertical, 20)
                    } else if store.windows.isEmpty {
                        Text("No windows detected")
                            .font(Theme.monoFont(10))
                            .foregroundStyle(Theme.text4)
                            .padding(.vertical, 20)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Window Row

struct WindowRow: View {
    let name: String
    let subtitle: String?
    let accentLevel: AccentLevel
    let bundleId: String
    let isExcluded: Bool
    let onToggle: () -> Void

    var dotColor: Color {
        Theme.appColor(for: bundleId).text
    }

    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 6 : 10) {
            Button(action: onToggle) {
                Image(systemName: isExcluded ? "square" : "checkmark.square.fill")
                    .font(.system(size: isSm ? 11 : 13))
                    .foregroundStyle(isExcluded ? Theme.text4 : Theme.accent)
            }
            .buttonStyle(.plain)

            RoundedRectangle(cornerRadius: 2)
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .opacity(isExcluded ? 0.35 : 1)

            Text(name)
                .font(Theme.mainFont(isSm ? 11 : 13, weight: .medium))
                .foregroundStyle(Theme.text1)
                .lineLimit(1)
                .opacity(isExcluded ? 0.35 : 1)

            Spacer()

            if let sub = subtitle {
                Text(sub)
                    .font(Theme.monoFont(isSm ? 8 : 9))
                    .foregroundStyle(Theme.text3)
                    .lineLimit(1)
                    .opacity(isExcluded ? 0.35 : 1)
            }
        }
        .padding(.vertical, isSm ? 6 : 9)
        .padding(.horizontal, isSm ? 6 : 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    private var displayText: String {
        if Theme.isASCII { return "// \(text)" }
        return text
    }

    var body: some View {
        Text(displayText)
            .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
            .foregroundStyle(Theme.text3)
            .tracking(Theme.isCyber ? 3 : 1.5)
            .padding(.bottom, isSm ? 8 : 12)
    }
}
