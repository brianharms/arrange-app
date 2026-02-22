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
                    ForEach(store.assignments, id: \.col) { assignment in
                    }

                    let assigned = store.assignments.filter { $0.window != nil }
                    ForEach(Array(assigned.enumerated()), id: \.offset) { _, item in
                        if let window = item.window {
                            WindowRow(
                                name: window.displayName,
                                size: window.shortSize,
                                accentLevel: store.accentLevel(col: item.col, app: item.app),
                                bundleId: window.bundleId
                            )
                        }
                    }

                    if assigned.isEmpty && !store.hasAccessibilityPermission {
                        Text("Grant accessibility permission to detect windows")
                            .font(Theme.monoFont(10))
                            .foregroundStyle(Theme.text4)
                            .padding(.vertical, 20)
                    } else if assigned.isEmpty {
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
    let size: String
    let accentLevel: AccentLevel
    let bundleId: String

    var dotColor: Color {
        switch accentLevel {
        case .primary:   return Theme.accent
        case .secondary: return Theme.accentDark
        case .none:      return Theme.appColor(for: bundleId).text
        }
    }

    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 6 : 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(dotColor)
                .frame(width: 8, height: 8)

            Text(name)
                .font(Theme.mainFont(isSm ? 11 : 13, weight: .medium))
                .foregroundStyle(Theme.text1)
                .lineLimit(1)

            Spacer()

            Text(size)
                .font(Theme.monoFont(isSm ? 8 : 9))
                .foregroundStyle(Theme.text4)
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
