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
    var isMinimized: Bool
    var isHidden: Bool

    var area: CGFloat {
        frame.width * frame.height
    }

    var displayName: String {
        if title.isEmpty { return appName }
        return appName
    }

    var subtitle: String? {
        let t = title.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, t != appName else { return nil }
        return t
    }

    /// Extract a short, meaningful label from the window title.
    /// For paths like "~/Desktop/Claude Projects/arrange", returns "arrange".
    /// For "user@host: ~/projects/foo", returns "foo".
    /// Falls back to the raw subtitle.
    var briefLabel: String? {
        guard let sub = subtitle else { return nil }
        // Strip common terminal prefixes (user@host:, etc.)
        let cleaned: String
        if let colonIdx = sub.lastIndex(of: ":") {
            cleaned = String(sub[sub.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
        } else {
            cleaned = sub
        }
        // If it looks like a path, take the last non-empty component
        if cleaned.contains("/") {
            let components = cleaned.split(separator: "/").map(String.init)
            if let last = components.last, !last.isEmpty {
                return last
            }
        }
        // If it's a reasonable length, use as-is
        if cleaned.count <= 30 { return cleaned }
        // Truncate long titles
        return String(cleaned.prefix(25)) + "…"
    }

    var shortSize: String {
        "\(Int(frame.width))×\(Int(frame.height))"
    }

    var stableKey: String { "\(pid)|\(title.isEmpty ? bundleId : title)" }
}
