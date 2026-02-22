import AppKit

class ScreenService {
    private var observer: NSObjectProtocol?

    func detectScreens() -> [ScreenInfo] {
        NSScreen.screens.enumerated().map { index, screen in
            let displayID = screen.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")
            ] as? UInt32 ?? UInt32(index)

            return ScreenInfo(
                id: displayID,
                name: screen.localizedName,
                frame: screen.frame,
                visibleFrame: screen.visibleFrame,
                isMain: screen == NSScreen.main
            )
        }
    }

    func observeChanges(handler: @escaping () -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in
            handler()
        }
    }

    func stopObserving() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
    }
}
