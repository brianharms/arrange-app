import Foundation
import AppKit

struct ScreenInfo: Identifiable {
    let id: UInt32          // CGDirectDisplayID
    let name: String
    let frame: CGRect       // Full frame in NSScreen coords
    let visibleFrame: CGRect // Excluding menu bar / dock
    let isMain: Bool

    var resolution: String {
        "\(Int(frame.width))×\(Int(frame.height))"
    }
}
