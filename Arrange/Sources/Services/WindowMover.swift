import Foundation
import ApplicationServices

struct WindowSnapshot {
    let windowID: UUID
    let axWindow: AXUIElement
    let frame: CGRect
}

class WindowMover {
    private var snapshots: [WindowSnapshot] = []

    var hasSnapshot: Bool { !snapshots.isEmpty }

    func snapshot(windows: [WindowInfo]) {
        snapshots = windows.map { w in
            WindowSnapshot(windowID: w.id, axWindow: w.axWindow, frame: w.frame)
        }
    }

    func restore(using service: AccessibilityService) {
        for snap in snapshots {
            service.setPosition(snap.axWindow, point: snap.frame.origin)
            service.setSize(snap.axWindow, size: snap.frame.size)
        }
        snapshots = []
    }

    func clear() {
        snapshots = []
    }
}
