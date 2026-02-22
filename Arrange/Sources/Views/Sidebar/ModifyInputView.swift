import SwiftUI

struct ModifyInputView: View {
    @Bindable var store: ArrangeStore

    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel("MODIFY")

            TextField("", text: $store.modifyText, prompt: Text("e.g. make VS Code larger").foregroundColor(Theme.placeholder))
                .textFieldStyle(.plain)
                .font(Theme.mainFont(isSm ? 11 : 13))
                .foregroundStyle(Theme.text1)
                .padding(.vertical, isSm ? 9 : 13)
                .padding(.horizontal, isSm ? 10 : 14)
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
                .themedBorder(radius: Theme.radiusMd, color: Theme.inputBorder)
                .onSubmit {
                    store.modifyWithClaude()
                }
        }
        .padding(.bottom, isSm ? 8 : 12)
    }
}
