import SwiftUI

@main
struct ArrangeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            Button("Show Arrange  ⌥⌘Space") {
                appDelegate.togglePanel()
            }
            Divider()
            Button("Settings...") {
                appDelegate.showSettings()
            }
            Divider()
            Button("Quit Arrange") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(systemName: "rectangle.split.3x3")
        }
    }
}
