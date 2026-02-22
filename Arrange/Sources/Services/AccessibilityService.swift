import AppKit
import ApplicationServices

class AccessibilityService {

    // MARK: - Permission

    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    // MARK: - Window Enumeration

    func listWindows() -> [WindowInfo] {
        var windows: [WindowInfo] = []

        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }

        for app in apps {
            let pid = app.processIdentifier
            let axApp = AXUIElementCreateApplication(pid)

            var windowsRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                axApp,
                kAXWindowsAttribute as CFString,
                &windowsRef
            )
            guard result == .success,
                  let axWindows = windowsRef as? [AXUIElement]
            else { continue }

            for axWindow in axWindows {
                guard let info = windowInfo(
                    from: axWindow,
                    pid: pid,
                    bundleId: app.bundleIdentifier ?? "",
                    appName: app.localizedName ?? "Unknown"
                ) else { continue }
                windows.append(info)
            }
        }

        return windows
    }

    // MARK: - Set Frame

    func setFrame(for window: WindowInfo, frame: CGRect) {
        setPosition(window.axWindow, point: frame.origin)
        setSize(window.axWindow, size: frame.size)
    }

    func setPosition(_ element: AXUIElement, point: CGPoint) {
        var p = point
        guard let value = AXValueCreate(.cgPoint, &p) else { return }
        AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, value)
    }

    func setSize(_ element: AXUIElement, size: CGSize) {
        var s = size
        guard let value = AXValueCreate(.cgSize, &s) else { return }
        AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, value)
    }

    // MARK: - Helpers

    private func windowInfo(
        from axWindow: AXUIElement,
        pid: pid_t,
        bundleId: String,
        appName: String
    ) -> WindowInfo? {
        // Skip minimized
        if boolAttr(axWindow, kAXMinimizedAttribute) == true { return nil }

        // Must be standard window
        let subrole = stringAttr(axWindow, kAXSubroleAttribute) ?? ""
        guard subrole == "AXStandardWindow" else { return nil }

        // Get position + size
        let pos = pointAttr(axWindow, kAXPositionAttribute) ?? .zero
        let size = sizeAttr(axWindow, kAXSizeAttribute) ?? .zero

        // Skip tiny windows
        guard size.width >= 100 && size.height >= 100 else { return nil }

        // Skip offscreen (different Space)
        let screens = NSScreen.screens
        let windowRect = CGRect(origin: pos, size: size)
        let onAnyScreen = screens.contains { screen in
            let axScreenFrame = nsToAX(screen.frame)
            return windowRect.intersects(axScreenFrame)
        }
        guard onAnyScreen else { return nil }

        let title = stringAttr(axWindow, kAXTitleAttribute) ?? ""

        return WindowInfo(
            pid: pid,
            axWindow: axWindow,
            bundleId: bundleId,
            appName: appName,
            title: title,
            frame: windowRect
        )
    }

    private func stringAttr(_ el: AXUIElement, _ attr: String) -> String? {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(el, attr as CFString, &ref)
        return ref as? String
    }

    private func boolAttr(_ el: AXUIElement, _ attr: String) -> Bool? {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(el, attr as CFString, &ref)
        return ref as? Bool
    }

    private func pointAttr(_ el: AXUIElement, _ attr: String) -> CGPoint? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success,
              let val = ref
        else { return nil }
        var point = CGPoint.zero
        AXValueGetValue(val as! AXValue, .cgPoint, &point)
        return point
    }

    private func sizeAttr(_ el: AXUIElement, _ attr: String) -> CGSize? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success,
              let val = ref
        else { return nil }
        var size = CGSize.zero
        AXValueGetValue(val as! AXValue, .cgSize, &size)
        return size
    }

    // MARK: - Coordinate Conversion

    /// Convert NSScreen frame (origin bottom-left) to AX frame (origin top-left)
    func nsToAX(_ nsRect: CGRect) -> CGRect {
        guard let primary = NSScreen.screens.first else { return nsRect }
        let h = primary.frame.height
        return CGRect(
            x: nsRect.origin.x,
            y: h - nsRect.origin.y - nsRect.height,
            width: nsRect.width,
            height: nsRect.height
        )
    }
}
