import SwiftUI

struct SavedLayoutsView: View {
    @Bindable var store: ArrangeStore
    @State private var showSavePopover = false
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionLabel("SAVED LAYOUTS")
                Spacer()
                Button(action: { showSavePopover = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
                .popover(isPresented: $showSavePopover, arrowEdge: .trailing) {
                    SaveLayoutPopover(store: store, isPresented: $showSavePopover)
                }
            }

            if store.savedLayouts.isEmpty {
                Text("No saved layouts")
                    .font(Theme.monoFont(isSm ? 9 : 10))
                    .foregroundStyle(Theme.text4)
                    .padding(.bottom, 8)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(store.savedLayouts) { layout in
                            SavedLayoutRow(layout: layout, store: store)
                        }
                    }
                }
                .frame(maxHeight: 100)
            }
        }
        .padding(.bottom, isSm ? 8 : 12)
    }
}

// MARK: - Row

struct SavedLayoutRow: View {
    let layout: SavedLayout
    @Bindable var store: ArrangeStore
    @State private var isHovered = false
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        HStack(spacing: 6) {
            Text(layout.name)
                .font(Theme.mainFont(isSm ? 11 : 12, weight: .medium))
                .foregroundStyle(Theme.text1)
                .lineLimit(1)

            Spacer()

            if isHovered {
                Button(action: { store.deleteLayout(id: layout.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.text3)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }

            Button(action: { store.triggerLayout(layout) }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isHovered ? Theme.accent : Theme.text3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, isSm ? 5 : 7)
        .padding(.horizontal, isSm ? 6 : 8)
        .background(isHovered ? Theme.bgSurface : Color.clear, in: RoundedRectangle(cornerRadius: Theme.radiusSm))
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.12), value: isHovered)
    }
}

// MARK: - Save Popover

struct SaveLayoutPopover: View {
    @Bindable var store: ArrangeStore
    @Binding var isPresented: Bool
    @State private var name = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save Layout")
                .font(Theme.mainFont(13, weight: .semibold))
                .foregroundStyle(Theme.text1)

            TextField("Layout name", text: $name)
                .textFieldStyle(.plain)
                .font(Theme.mainFont(13))
                .foregroundStyle(Theme.text1)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusSm))
                .themedBorder(radius: Theme.radiusSm, color: Theme.inputBorder)
                .focused($focused)
                .onSubmit { save() }

            HStack {
                Spacer()
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.plain)
                    .font(Theme.mainFont(12))
                    .foregroundStyle(Theme.text3)
                    .padding(.trailing, 8)

                Button("Save") { save() }
                    .buttonStyle(.plain)
                    .font(Theme.mainFont(12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        name.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.accent.opacity(0.4) : Theme.accent,
                        in: RoundedRectangle(cornerRadius: Theme.radiusSm)
                    )
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
        .frame(width: 220)
        .onAppear { focused = true }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.saveCurrentLayout(name: trimmed)
        isPresented = false
    }
}
