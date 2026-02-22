import Foundation
import ApplicationServices

struct WindowInfo: Identifiable {
    let id = UUID()
    let pid: pid_t
    let axWindow: AXUIElement
    let bundleId: String
    let appName: String
    let title: String
    var frame: CGRect

    var area: CGFloat {
        frame.width * frame.height
    }

    var displayName: String {
        if title.isEmpty { return appName }
        return appName
    }

    var shortSize: String {
        "\(Int(frame.width))×\(Int(frame.height))"
    }
}
