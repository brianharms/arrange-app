# Arrange — One-Shot Rebuild Prompt

> **Purpose**: This document is a complete BUILD INSTRUCTION SET for the "Arrange" macOS window arrangement app. A fresh Claude instance with ZERO context can execute it and produce a functionally identical app from scratch.

---

## 1. Project Overview

Arrange is a macOS menu-bar utility that detects open windows via the Accessibility API, displays them in a flex-based layout canvas, and repositions them on screen with a single click. It features:

- **Menu bar app** (LSUIElement) with floating NSPanel triggered by global hotkey (Option+Command+Space)
- **Flex-based layout presets** that adapt to window count (1-7+)
- **Drag-and-drop** window reordering within the canvas
- **Resizable seams** between blocks (drag to adjust flex ratios)
- **4-dimensional theme system**: Style (6) x Font (3) x Color (11) x Mode (dark/light)
- **Claude API integration** for natural language layout modification
- **Undo** for both layout changes and window positions
- **Multi-monitor support** with display selection

**Tech stack**: Swift, SwiftUI, macOS 14.0+, xcodegen, HotKey (soffes/HotKey 0.2.1+)
**Bundle ID**: com.ritualindustries.arrange
**Fonts**: Space Grotesk, JetBrains Mono (bundled TTF/OTF in Arrange/Resources/Fonts/)

---

## 2. File Tree

```
arrange/
├── project.yml
├── Makefile
├── .gitignore
├── Arrange/
│   ├── Info.plist
│   ├── Resources/
│   │   ├── Arrange.entitlements
│   │   └── Fonts/
│   │       ├── SpaceGrotesk-Regular.ttf
│   │       ├── SpaceGrotesk-Light.ttf
│   │       ├── SpaceGrotesk-Medium.ttf
│   │       ├── SpaceGrotesk-SemiBold.ttf
│   │       ├── SpaceGrotesk-Bold.ttf
│   │       ├── JetBrainsMono-Regular.ttf
│   │       ├── JetBrainsMono-Light.ttf
│   │       ├── JetBrainsMono-Medium.ttf
│   │       ├── JetBrainsMono-SemiBold.ttf
│   │       └── JetBrainsMono-Bold.ttf
│   └── Sources/
│       ├── ArrangeApp.swift
│       ├── AppDelegate.swift
│       ├── Theme.swift
│       ├── Models/
│       │   ├── LayoutPreset.swift
│       │   ├── LayoutState.swift
│       │   ├── WindowInfo.swift
│       │   └── ScreenInfo.swift
│       ├── Services/
│       │   ├── AccessibilityService.swift
│       │   ├── LayoutEngine.swift
│       │   ├── ClaudeService.swift
│       │   ├── ScreenService.swift
│       │   └── WindowMover.swift
│       ├── Stores/
│       │   └── ArrangeStore.swift
│       └── Views/
│           ├── PanelView.swift
│           ├── TopBar.swift
│           ├── LayoutTabsView.swift
│           ├── MonitorBar.swift
│           ├── SettingsView.swift
│           ├── Canvas/
│           │   ├── CanvasView.swift
│           │   ├── AppBlockView.swift
│           │   └── SeamView.swift
│           └── Sidebar/
│               ├── WindowListView.swift
│               ├── ActionButtons.swift
│               └── ModifyInputView.swift
```

**IMPORTANT**: Font files (TTF/OTF) must be downloaded separately. They are binary files and cannot be generated from this prompt. Download Space Grotesk from Google Fonts and JetBrains Mono from JetBrains and place them in `Arrange/Resources/Fonts/`.

---

## 3. Build Steps — Execute in This Order

### Step 1: Create project.yml

This is the xcodegen project specification. It defines the target, dependencies, build settings, and code signing configuration.

```yaml
name: Arrange
options:
  bundleIdPrefix: com.ritualindustries
  deploymentTarget:
    macOS: "14.0"
  createIntermediateGroups: true
  groupSortPosition: none

packages:
  HotKey:
    url: https://github.com/soffes/HotKey
    from: "0.2.1"

targets:
  Arrange:
    type: application
    platform: macOS
    sources:
      - path: Arrange/Sources
      - path: Arrange/Resources
        excludes:
          - "Arrange.entitlements"
        buildPhase: resources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.ritualindustries.arrange
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: "1"
        SWIFT_VERSION: "5"
        MACOSX_DEPLOYMENT_TARGET: "14.0"
        CODE_SIGN_ENTITLEMENTS: Arrange/Resources/Arrange.entitlements
        CODE_SIGN_IDENTITY: ""
        CODE_SIGNING_ALLOWED: NO
        CODE_SIGNING_REQUIRED: NO
        ONLY_ACTIVE_ARCH: YES
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
    info:
      path: Arrange/Info.plist
      properties:
        LSUIElement: true
        ATSApplicationFontsPath: Fonts
        CFBundleIconFile: AppIcon
        NSAccessibilityUsageDescription: "Arrange needs accessibility access to detect and reposition your windows."
        NSHumanReadableCopyright: "© 2026 Ritual Industries"
    dependencies:
      - package: HotKey
```

### Step 2: Create Makefile

```makefile
.PHONY: generate build run clean

generate:
	xcodegen generate

build: generate
	xattr -cr Arrange/
	xcodebuild build -project Arrange.xcodeproj -scheme Arrange -configuration Debug -derivedDataPath build ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
	xattr -cr build/Build/Products/Debug/Arrange.app
	codesign --force --sign - --entitlements Arrange/Resources/Arrange.entitlements --deep build/Build/Products/Debug/Arrange.app

run: build
	open build/Build/Products/Debug/Arrange.app

clean:
	rm -rf build Arrange.xcodeproj
```

### Step 3: Create .gitignore

```
build/
Arrange.xcodeproj/
.DS_Store
*.swp
```

### Step 4: Create Arrange/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ATSApplicationFontsPath</key>
	<string>Fonts</string>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSAccessibilityUsageDescription</key>
	<string>Arrange needs accessibility access to detect and reposition your windows.</string>
	<key>NSHumanReadableCopyright</key>
	<string>© 2026 Ritual Industries</string>
</dict>
</plist>
```

### Step 5: Create Arrange/Resources/Arrange.entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<false/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
```

### Step 6: Create Data Models

#### Arrange/Sources/Models/WindowInfo.swift

```swift
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
```

#### Arrange/Sources/Models/ScreenInfo.swift

```swift
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
```

#### Arrange/Sources/Models/LayoutPreset.swift

```swift
import Foundation

struct LayoutPreset: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    var columns: [Column]
    var alignRows: Bool

    struct Column: Codable, Equatable {
        var flex: Double
        var apps: [AppSlot]
    }

    struct AppSlot: Codable, Equatable {
        var id: String
        var flex: Double
    }

    var totalSlots: Int {
        columns.reduce(0) { $0 + $1.apps.count }
    }

    // MARK: - Dynamic Presets

    private static func slot(_ i: Int) -> AppSlot {
        AppSlot(id: "app-\(i)", flex: 1)
    }

    private static func slot(_ i: Int, flex: Double) -> AppSlot {
        AppSlot(id: "app-\(i)", flex: flex)
    }

    static func presets(forCount n: Int) -> [LayoutPreset] {
        switch n {
        case 0, 1:
            return [
                LayoutPreset(id: "single", name: "Single",
                    columns: [Column(flex: 1, apps: [slot(0)])],
                    alignRows: false),
            ]
        case 2:
            return [
                LayoutPreset(id: "halves", name: "Halves",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                    ], alignRows: false),
                LayoutPreset(id: "focus2", name: "Focus",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                    ], alignRows: false),
                LayoutPreset(id: "stack2", name: "Stack",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                    ], alignRows: false),
            ]
        case 3:
            return [
                LayoutPreset(id: "thirds", name: "Thirds",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "focus3", name: "Focus",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "sidebar3", name: "Sidebar",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 2, apps: [slot(2)]),
                    ], alignRows: false),
            ]
        case 4:
            return [
                LayoutPreset(id: "grid4", name: "Grid 2×2",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                    ], alignRows: true),
                LayoutPreset(id: "focus4", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2), slot(3)]),
                    ], alignRows: false),
                LayoutPreset(id: "cols4", name: "Columns",
                    columns: [
                        Column(flex: 1, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2)]),
                        Column(flex: 1, apps: [slot(3)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade4", name: "Cascade",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                    ], alignRows: false),
            ]
        case 5:
            return [
                LayoutPreset(id: "focus5", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: [slot(1), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4)]),
                    ], alignRows: true),
                LayoutPreset(id: "grid5", name: "Grid 3+2",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(3)]),
                        Column(flex: 1, apps: [slot(1), slot(4)]),
                        Column(flex: 1, apps: [slot(2)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade5", name: "Cascade",
                    columns: [
                        Column(flex: 2, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4)]),
                    ], alignRows: false),
            ]
        case 6:
            return [
                LayoutPreset(id: "grid6", name: "Grid 3×2",
                    columns: [
                        Column(flex: 2, apps: [slot(0, flex: 1), slot(1, flex: 0.55)]),
                        Column(flex: 1.5, apps: [slot(2, flex: 1), slot(3, flex: 0.55)]),
                        Column(flex: 1, apps: [slot(4, flex: 1), slot(5, flex: 0.55)]),
                    ], alignRows: true),
                LayoutPreset(id: "focus6", name: "Focus",
                    columns: [
                        Column(flex: 3, apps: [slot(0)]),
                        Column(flex: 2, apps: [slot(1), slot(2), slot(3), slot(4), slot(5)]),
                    ], alignRows: false),
                LayoutPreset(id: "cascade6", name: "Cascade",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1.5, apps: [slot(1, flex: 1.2), slot(2)]),
                        Column(flex: 1, apps: [slot(3), slot(4), slot(5)]),
                    ], alignRows: false),
                LayoutPreset(id: "trident6", name: "Trident",
                    columns: [
                        Column(flex: 1, apps: [slot(0), slot(1)]),
                        Column(flex: 1, apps: [slot(2), slot(3)]),
                        Column(flex: 1, apps: [slot(4), slot(5)]),
                    ], alignRows: true),
            ]
        default: // 7+
            return [
                LayoutPreset(id: "grid", name: "Grid",
                    columns: gridColumns(for: n),
                    alignRows: true),
                LayoutPreset(id: "focus", name: "Focus",
                    columns: [
                        Column(flex: 2.5, apps: [slot(0)]),
                        Column(flex: 1, apps: (1..<n).map { slot($0) }),
                    ], alignRows: false),
                LayoutPreset(id: "cockpit", name: "Cockpit",
                    columns: cockpitColumns(for: n),
                    alignRows: false),
            ]
        }
    }

    private static func gridColumns(for n: Int) -> [Column] {
        let cols = n <= 4 ? 2 : (n <= 9 ? 3 : 4)
        let perCol = n / cols
        let extra = n % cols
        var columns: [Column] = []
        var idx = 0
        for c in 0..<cols {
            let count = perCol + (c < extra ? 1 : 0)
            let apps = (0..<count).map { _ -> AppSlot in
                let s = slot(idx)
                idx += 1
                return s
            }
            columns.append(Column(flex: 1, apps: apps))
        }
        return columns
    }

    private static func cockpitColumns(for n: Int) -> [Column] {
        let sideCount = (n - 1) / 2
        let rightCount = n - 1 - sideCount
        var idx = 0
        let leftApps = (0..<sideCount).map { _ -> AppSlot in
            let s = slot(idx); idx += 1; return s
        }
        let centerApp = [slot(idx)]; idx += 1
        let rightApps = (0..<rightCount).map { _ -> AppSlot in
            let s = slot(idx); idx += 1; return s
        }
        return [
            Column(flex: 0.8, apps: leftApps),
            Column(flex: 2.5, apps: centerApp),
            Column(flex: 0.8, apps: rightApps),
        ]
    }
}
```

#### Arrange/Sources/Models/LayoutState.swift

```swift
import Foundation
import Observation

@Observable
class LayoutState {
    var preset: LayoutPreset
    private var undoStack: [LayoutPreset] = []

    init(preset: LayoutPreset) {
        self.preset = preset
    }

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    func pushUndo() {
        undoStack.append(preset)
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
    }

    @discardableResult
    func undo() -> Bool {
        guard let previous = undoStack.popLast() else { return false }
        preset = previous
        return true
    }

    func reset(to preset: LayoutPreset) {
        pushUndo()
        self.preset = preset
    }
}
```

### Step 7: Create Services

#### Arrange/Sources/Services/AccessibilityService.swift

```swift
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
```

#### Arrange/Sources/Services/LayoutEngine.swift

```swift
import AppKit
import SwiftUI

struct ResolvedRect {
    let col: Int
    let app: Int
    let rect: CGRect
}

struct SlotArea: Comparable {
    let col: Int
    let app: Int
    let area: Double

    static func < (lhs: SlotArea, rhs: SlotArea) -> Bool {
        lhs.area < rhs.area
    }
}

enum AccentLevel {
    case primary
    case secondary
    case none
}

class LayoutEngine {

    // MARK: - Resolve Flex → CGRect

    /// Resolves preset flex values into actual pixel rects within given bounds.
    /// Bounds should be in the target coordinate system (AX coords for window moving,
    /// or local coords for canvas preview).
    func resolve(preset: LayoutPreset, in bounds: CGRect) -> [ResolvedRect] {
        let seamW = Theme.seamWidth
        let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * seamW
        let availableWidth = bounds.width - totalVSeams
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }

        var results: [ResolvedRect] = []
        var x = bounds.minX

        for (colIndex, column) in preset.columns.enumerated() {
            let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)
            let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * seamW
            let availableHeight = bounds.height - totalHSeams
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }

            var y = bounds.minY

            for (appIndex, app) in column.apps.enumerated() {
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)
                let rect = CGRect(x: x, y: y, width: colWidth, height: appHeight)
                results.append(ResolvedRect(col: colIndex, app: appIndex, rect: rect))
                y += appHeight + seamW
            }

            x += colWidth + seamW
        }

        return results
    }

    // MARK: - Window Assignment

    /// Assigns windows to preset slots by area heuristic (largest window → largest slot).
    /// Returns an array of (col, app, window?) tuples for every slot.
    func assign(windows: [WindowInfo], to preset: LayoutPreset) -> [(col: Int, app: Int, window: WindowInfo?)] {
        // Calculate proportional area for each slot
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        var slotAreas: [SlotArea] = []

        for (colIndex, column) in preset.columns.enumerated() {
            let colProportion = column.flex / totalColFlex
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            for (appIndex, app) in column.apps.enumerated() {
                let appProportion = app.flex / totalAppFlex
                let area = colProportion * appProportion
                slotAreas.append(SlotArea(col: colIndex, app: appIndex, area: area))
            }
        }

        // Sort slots by area descending
        let sortedSlots = slotAreas.sorted { $0.area > $1.area }

        // Sort windows by current area descending
        let sortedWindows = windows.sorted { $0.area > $1.area }

        // Match 1:1
        var assignments: [String: WindowInfo] = [:]  // "col-app" → window
        for (i, slot) in sortedSlots.enumerated() {
            if i < sortedWindows.count {
                assignments["\(slot.col)-\(slot.app)"] = sortedWindows[i]
            }
        }

        // Build result array in slot order
        var result: [(col: Int, app: Int, window: WindowInfo?)] = []
        for (colIndex, column) in preset.columns.enumerated() {
            for appIndex in 0..<column.apps.count {
                let key = "\(colIndex)-\(appIndex)"
                result.append((col: colIndex, app: appIndex, window: assignments[key]))
            }
        }

        return result
    }

    // MARK: - Accent Calculation

    func accentLevel(for preset: LayoutPreset, col: Int, app: Int) -> AccentLevel {
        let areas = slotAreas(for: preset)
        let sorted = areas.sorted { $0.area > $1.area }

        guard sorted.count >= 2 else {
            if sorted.count == 1 && sorted[0].col == col && sorted[0].app == app {
                return .primary
            }
            return .none
        }

        if sorted[0].col == col && sorted[0].app == app { return .primary }
        if sorted[1].col == col && sorted[1].app == app { return .secondary }
        return .none
    }

    func slotAreas(for preset: LayoutPreset) -> [SlotArea] {
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        var areas: [SlotArea] = []

        for (colIndex, column) in preset.columns.enumerated() {
            let colProportion = column.flex / totalColFlex
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            for (appIndex, app) in column.apps.enumerated() {
                let appProportion = app.flex / totalAppFlex
                areas.append(SlotArea(
                    col: colIndex, app: appIndex,
                    area: colProportion * appProportion
                ))
            }
        }

        return areas
    }

    // MARK: - Screen Coordinate Resolution

    /// Resolves preset for actual screen placement. Converts NSScreen visibleFrame to AX coords.
    func resolveForScreen(preset: LayoutPreset, screen: ScreenInfo) -> [ResolvedRect] {
        guard let primary = NSScreen.screens.first else { return [] }
        let h = primary.frame.height
        let vis = screen.visibleFrame

        // Convert NSScreen visibleFrame to AX coordinates (top-left origin)
        let axBounds = CGRect(
            x: vis.origin.x,
            y: h - vis.origin.y - vis.height,
            width: vis.width,
            height: vis.height
        )

        return resolve(preset: preset, in: axBounds)
    }
}
```

#### Arrange/Sources/Services/ClaudeService.swift

```swift
import Foundation

class ClaudeService {

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Request: Codable {
        let model: String
        let max_tokens: Int
        let messages: [Message]
        let system: String
    }

    struct Response: Codable {
        let content: [ContentBlock]

        struct ContentBlock: Codable {
            let type: String
            let text: String?
        }
    }

    func modify(
        preset: LayoutPreset,
        instruction: String,
        apiKey: String
    ) async throws -> LayoutPreset {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let presetJSON = String(data: try encoder.encode(preset), encoding: .utf8) ?? "{}"

        let systemPrompt = """
        You are a window layout assistant. You receive a JSON layout preset and a user instruction.
        Modify the preset according to the instruction and return ONLY the modified JSON.
        The layout has columns (each with a flex value) containing apps (each with an id and flex value).
        Flex values control proportional sizing. Higher flex = larger.
        alignRows controls whether rows across columns are aligned.
        Return valid JSON only, no markdown, no explanation.
        """

        let userMessage = """
        Current layout:
        \(presetJSON)

        Instruction: \(instruction)

        Return the modified layout JSON only.
        """

        let request = Request(
            model: "claude-sonnet-4-6",
            max_tokens: 2048,
            messages: [Message(role: "user", content: userMessage)],
            system: systemPrompt
        )

        let requestData = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.httpBody = requestData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ClaudeError.apiError(statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        let apiResponse = try JSONDecoder().decode(Response.self, from: data)

        guard let text = apiResponse.content.first?.text else {
            throw ClaudeError.emptyResponse
        }

        // Extract JSON from response (handle potential markdown wrapping)
        let jsonText = extractJSON(from: text)

        guard let jsonData = jsonText.data(using: .utf8) else {
            throw ClaudeError.invalidJSON
        }

        let modified = try JSONDecoder().decode(LayoutPreset.self, from: jsonData)
        return modified
    }

    private func extractJSON(from text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove markdown code fences if present
        if t.hasPrefix("```") {
            if let start = t.firstIndex(of: "\n") {
                t = String(t[t.index(after: start)...])
            }
            if t.hasSuffix("```") {
                t = String(t.dropLast(3))
            }
            t = t.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return t
    }

    enum ClaudeError: LocalizedError {
        case apiError(Int, String)
        case emptyResponse
        case invalidJSON

        var errorDescription: String? {
            switch self {
            case .apiError(let code, let body):
                return "API error \(code): \(body.prefix(200))"
            case .emptyResponse:
                return "Empty response from Claude"
            case .invalidJSON:
                return "Could not parse layout JSON"
            }
        }
    }
}
```

#### Arrange/Sources/Services/ScreenService.swift

```swift
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
```

#### Arrange/Sources/Services/WindowMover.swift

```swift
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
```

### Step 8: Create the Store

#### Arrange/Sources/Stores/ArrangeStore.swift

```swift
import Foundation
import SwiftUI
import Observation

@Observable
class ArrangeStore {
    // MARK: - State

    var windows: [WindowInfo] = []
    var screens: [ScreenInfo] = []
    var selectedScreenIndex: Int = 0
    var selectedPresetIndex: Int = 0
    var layoutState: LayoutState
    var modifyText: String = ""
    var statusText: String = ""
    var hasAccessibilityPermission: Bool = false
    var isLoading: Bool = false
    var panelSize: Theme.PanelSize {
        get { ThemeConfig.shared.panelSize }
        set { ThemeConfig.shared.panelSize = newValue }
    }
    var themeConfig = ThemeConfig.shared

    // Drag state
    var dragSource: (col: Int, app: Int)?
    var dropTarget: (col: Int, app: Int)?
    var isDragging: Bool = false
    var dragPosition: CGPoint?
    var seamDragSnapshot: LayoutPreset?

    // Manual window-to-slot assignments (overrides auto-assignment after user swaps)
    private var manualAssignments: [(col: Int, app: Int, window: WindowInfo?)]?

    // Settings
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "claudeAPIKey") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "claudeAPIKey") }
    }

    // MARK: - Services

    let accessibilityService = AccessibilityService()
    let screenService = ScreenService()
    let layoutEngine = LayoutEngine()
    let windowMover = WindowMover()
    let claudeService = ClaudeService()

    // Available presets (regenerated when window count changes)
    var availablePresets: [LayoutPreset] = LayoutPreset.presets(forCount: 0)

    // MARK: - Init

    init() {
        let presets = LayoutPreset.presets(forCount: 0)
        availablePresets = presets
        layoutState = LayoutState(preset: presets[0])
    }

    // MARK: - Computed

    var currentPreset: LayoutPreset {
        get { layoutState.preset }
        set { layoutState.preset = newValue }
    }

    var selectedScreen: ScreenInfo? {
        guard selectedScreenIndex < screens.count else { return nil }
        return screens[selectedScreenIndex]
    }

    var assignments: [(col: Int, app: Int, window: WindowInfo?)] {
        manualAssignments ?? layoutEngine.assign(windows: windows, to: currentPreset)
    }

    func windowFor(col: Int, app: Int) -> WindowInfo? {
        assignments.first { $0.col == col && $0.app == app }?.window
    }

    func accentLevel(col: Int, app: Int) -> AccentLevel {
        layoutEngine.accentLevel(for: currentPreset, col: col, app: app)
    }

    // MARK: - Refresh

    func refresh() {
        screens = screenService.detectScreens()
        if selectedScreenIndex >= screens.count {
            selectedScreenIndex = 0
        }
        if hasAccessibilityPermission {
            windows = accessibilityService.listWindows()
        }
        regeneratePresets()

        screenService.observeChanges { [weak self] in
            self?.screens = self?.screenService.detectScreens() ?? []
        }
    }

    // MARK: - Preset Selection

    func selectPreset(at index: Int) {
        guard index < availablePresets.count else { return }
        layoutState.pushUndo()
        selectedPresetIndex = index
        layoutState.preset = availablePresets[index]
        manualAssignments = nil
        statusText = currentPreset.name
    }

    func resetPreset() {
        guard selectedPresetIndex < availablePresets.count else { return }
        layoutState.reset(to: availablePresets[selectedPresetIndex])
        manualAssignments = nil
        statusText = "Reset to default"
    }

    // MARK: - Apply

    func apply() {
        guard let screen = selectedScreen else {
            statusText = "No screen selected"
            return
        }
        let frames = layoutEngine.resolveForScreen(preset: currentPreset, screen: screen)
        let assigned = assignments
        windowMover.snapshot(windows: windows)

        var moved = 0
        for assignment in assigned {
            guard let window = assignment.window else { continue }
            if let resolved = frames.first(where: { $0.col == assignment.col && $0.app == assignment.app }) {
                accessibilityService.setFrame(for: window, frame: resolved.rect)
                moved += 1
            }
        }
        statusText = "\(moved) windows arranged"
    }

    // MARK: - Undo

    func undo() {
        if windowMover.hasSnapshot {
            windowMover.restore(using: accessibilityService)
            statusText = "Windows restored"
        } else if layoutState.undo() {
            statusText = "Layout restored"
        } else {
            statusText = "Nothing to undo"
        }
    }

    // MARK: - Block Swap

    func swapBlocks(from: (col: Int, app: Int), to: (col: Int, app: Int)) {
        guard from.col != to.col || from.app != to.app else { return }

        // Materialize current assignments
        var current = assignments

        guard let fromIdx = current.firstIndex(where: { $0.col == from.col && $0.app == from.app }),
              let toIdx = current.firstIndex(where: { $0.col == to.col && $0.app == to.app })
        else { return }

        // Swap only the window references — grid layout stays the same
        let tempWindow = current[fromIdx].window
        current[fromIdx] = (col: current[fromIdx].col, app: current[fromIdx].app, window: current[toIdx].window)
        current[toIdx] = (col: current[toIdx].col, app: current[toIdx].app, window: tempWindow)

        manualAssignments = current
    }

    // MARK: - Seam Drag

    func adjustColumnFlex(leftCol: Int, delta: Double) {
        guard let snapshot = seamDragSnapshot else { return }
        guard leftCol >= 0 && leftCol + 1 < snapshot.columns.count else { return }
        var preset = currentPreset
        let snapshotLeft = snapshot.columns[leftCol].flex
        let snapshotRight = snapshot.columns[leftCol + 1].flex
        let combined = snapshotLeft + snapshotRight
        let minFlex = combined * 0.12

        let newLeft = max(minFlex, min(combined - minFlex, snapshotLeft + delta))
        let newRight = combined - newLeft

        preset.columns[leftCol].flex = newLeft
        preset.columns[leftCol + 1].flex = newRight
        currentPreset = preset
    }

    func adjustAppFlex(col: Int, aboveApp: Int, delta: Double) {
        guard let snapshot = seamDragSnapshot else { return }
        guard col < snapshot.columns.count,
              aboveApp >= 0 && aboveApp + 1 < snapshot.columns[col].apps.count
        else { return }

        var preset = currentPreset
        let snapshotAbove = snapshot.columns[col].apps[aboveApp].flex
        let snapshotBelow = snapshot.columns[col].apps[aboveApp + 1].flex
        let combined = snapshotAbove + snapshotBelow
        let minFlex = combined * 0.15

        let newAbove = max(minFlex, min(combined - minFlex, snapshotAbove + delta))
        let newBelow = combined - newAbove

        preset.columns[col].apps[aboveApp].flex = newAbove
        preset.columns[col].apps[aboveApp + 1].flex = newBelow
        currentPreset = preset
    }

    func beginSeamDrag() {
        layoutState.pushUndo()
        seamDragSnapshot = currentPreset
    }

    func endSeamDrag() {
        seamDragSnapshot = nil
    }

    // MARK: - Claude Modify

    func modifyWithClaude() {
        guard !modifyText.isEmpty else { return }
        guard !apiKey.isEmpty else {
            statusText = "Set API key in menu bar → Settings"
            return
        }
        isLoading = true
        statusText = "Asking Claude..."
        let instruction = modifyText
        modifyText = ""

        Task {
            do {
                let modified = try await claudeService.modify(
                    preset: currentPreset,
                    instruction: instruction,
                    apiKey: apiKey
                )
                await MainActor.run {
                    layoutState.pushUndo()
                    currentPreset = modified
                    isLoading = false
                    statusText = "Layout modified"
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    statusText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Private

    private func regeneratePresets() {
        let count = max(1, windows.count)
        availablePresets = LayoutPreset.presets(forCount: count)
        selectedPresetIndex = 0
        layoutState = LayoutState(preset: availablePresets[0])
        manualAssignments = nil
    }
}
```

### Step 9: Theme System — `Arrange/Sources/Theme.swift`

This is the MOST CRITICAL file. Every view depends on it. It defines the 4-dimensional theme system: Style × Font × Color × Mode.

Create `Arrange/Sources/Theme.swift` with this EXACT content:

```swift
import SwiftUI
import AppKit

// MARK: - Theme Style

enum ThemeStyle: String, CaseIterable {
    case `default`, brutalist, soft, tight, ascii, cyber

    var displayName: String {
        switch self {
        case .default:   return "Default"
        case .brutalist: return "Brutalist"
        case .soft:      return "Soft"
        case .tight:     return "Tight"
        case .ascii:     return "ASCII"
        case .cyber:     return "Cyber"
        }
    }
}

// MARK: - Theme Font

enum ThemeFont: String, CaseIterable {
    case grotesk, mono, system

    var displayName: String {
        switch self {
        case .grotesk: return "Grotesk"
        case .mono:    return "Mono"
        case .system:  return "System"
        }
    }
}

// MARK: - Theme Color

enum ThemeColor: String, CaseIterable {
    case red, orange, amber, green, teal, cyan, blue, violet, rose, grey, bw

    var displayName: String {
        switch self {
        case .bw: return "B&W"
        default:  return rawValue.capitalized
        }
    }

    var hex: UInt32 {
        switch self {
        case .red:    return 0xE53935
        case .orange: return 0xE85002
        case .amber:  return 0xF59E0B
        case .green:  return 0x43A047
        case .teal:   return 0x0D9488
        case .cyan:   return 0x00BCD4
        case .blue:   return 0x2196F3
        case .violet: return 0x8B5CF6
        case .rose:   return 0xE91E63
        case .grey:   return 0x888888
        case .bw:     return 0x000000
        }
    }

    var hoverHex: UInt32 {
        switch self {
        case .red:    return 0xEF5350
        case .orange: return 0xFF6010
        case .amber:  return 0xFBBF24
        case .green:  return 0x56B85A
        case .teal:   return 0x14B8A6
        case .cyan:   return 0x22D0E8
        case .blue:   return 0x42A5F5
        case .violet: return 0xA078FF
        case .rose:   return 0xF06292
        case .grey:   return 0x999999
        case .bw:     return 0x000000
        }
    }

    var darkHex: UInt32 {
        switch self {
        case .red:    return 0xC62828
        case .orange: return 0xC13A00
        case .amber:  return 0xD97706
        case .green:  return 0x2E7D32
        case .teal:   return 0x0F766E
        case .cyan:   return 0x0097A7
        case .blue:   return 0x1565C0
        case .violet: return 0x6A3AC8
        case .rose:   return 0xC2185B
        case .grey:   return 0x666666
        case .bw:     return 0x000000
        }
    }

    static var mainColors: [ThemeColor] {
        [.red, .orange, .amber, .green, .teal, .cyan, .blue, .violet, .rose]
    }

    static var specialColors: [ThemeColor] {
        [.grey, .bw]
    }
}

// MARK: - Theme Config (Observable)

@Observable
class ThemeConfig {
    static let shared = ThemeConfig()

    var isDark: Bool {
        didSet { UserDefaults.standard.set(isDark, forKey: "themeIsDark") }
    }
    var style: ThemeStyle {
        didSet { UserDefaults.standard.set(style.rawValue, forKey: "themeStyle") }
    }
    var font: ThemeFont {
        didSet { UserDefaults.standard.set(font.rawValue, forKey: "themeFont") }
    }
    var colorChoice: ThemeColor {
        didSet { UserDefaults.standard.set(colorChoice.rawValue, forKey: "themeColor") }
    }
    var panelSize: Theme.PanelSize = .lg

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "themeIsDark") != nil {
            isDark = defaults.bool(forKey: "themeIsDark")
        } else {
            isDark = true
        }
        if let s = defaults.string(forKey: "themeStyle").flatMap(ThemeStyle.init(rawValue:)) {
            style = s
        } else {
            style = .default
        }
        if let f = defaults.string(forKey: "themeFont").flatMap(ThemeFont.init(rawValue:)) {
            font = f
        } else {
            font = .grotesk
        }
        if let c = defaults.string(forKey: "themeColor").flatMap(ThemeColor.init(rawValue:)) {
            colorChoice = c
        } else {
            colorChoice = .orange
        }
    }
}

// MARK: - Theme

enum Theme {
    private static var config: ThemeConfig { ThemeConfig.shared }

    // MARK: - Style Helpers

    static var isASCII: Bool { config.style == .ascii }
    static var isCyber: Bool { config.style == .cyber }
    static var isGrey: Bool  { config.colorChoice == .grey }
    static var isBW: Bool    { config.colorChoice == .bw }

    // MARK: - Accent Colors

    static var accent: Color {
        if isBW { return config.isDark ? .white : .black }
        return Color(hex: config.colorChoice.hex)
    }

    static var accentHover: Color {
        if isBW { return config.isDark ? Color(hex: 0xCCCCCC) : Color(hex: 0x333333) }
        return Color(hex: config.colorChoice.hoverHex)
    }

    static var accentDark: Color {
        if isBW { return config.isDark ? Color(hex: 0xAAAAAA) : Color(hex: 0x555555) }
        return Color(hex: config.colorChoice.darkHex)
    }

    // MARK: - Backgrounds (warm-toned light mode)

    static var bgPage: Color    { config.isDark ? Color(hex: 0x0A0A0A) : Color(hex: 0xF0ECE4) }
    static var bgPanel: Color   { config.isDark ? Color(hex: 0x111111) : Color(hex: 0xFAF7F2) }
    static var bgCanvas: Color  { config.isDark ? Color(hex: 0x0E0E0E) : Color(hex: 0xF2EDE5) }
    static var bgSurface: Color { config.isDark ? Color(hex: 0x161616) : Color(hex: 0xEDE8E0) }
    static var bgActive: Color  { config.isDark ? Color(hex: 0x1A1A1A) : Color(hex: 0xE5DFD5) }

    // MARK: - Borders

    static var border: Color       { config.isDark ? Color(hex: 0x1C1C1C) : Color(hex: 0xD8D0C5) }
    static var borderActive: Color { config.isDark ? Color(hex: 0x2A2A2A) : Color(hex: 0xC0B8AA) }
    static var inputBorder: Color  { config.isDark ? Color(hex: 0x222222) : Color(hex: 0xD0C8BC) }

    // MARK: - Text

    static var text1: Color { config.isDark ? Color(hex: 0xE8E8E8) : Color(hex: 0x2A2420) }
    static var text2: Color { config.isDark ? Color(hex: 0x888888) : Color(hex: 0x807870) }
    static var text3: Color { config.isDark ? Color(hex: 0x555555) : Color(hex: 0xA09888) }
    static var text4: Color { config.isDark ? Color(hex: 0x444444) : Color(hex: 0xB0A898) }
    static var text5: Color { config.isDark ? Color(hex: 0x333333) : Color(hex: 0xC0B8B0) }
    static var placeholder: Color { config.isDark ? Color(hex: 0x666666) : Color(hex: 0x9A9080) }

    // MARK: - Radii (style-dependent)

    static var radiusLg: CGFloat {
        switch config.style {
        case .default:   return 20
        case .brutalist:  return 0
        case .soft:      return 28
        case .tight:     return 4
        case .ascii:     return 0
        case .cyber:     return 2
        }
    }

    static var radiusMd: CGFloat {
        switch config.style {
        case .default:   return 10
        case .brutalist:  return 0
        case .soft:      return 16
        case .tight:     return 3
        case .ascii:     return 0
        case .cyber:     return 2
        }
    }

    static var radiusSm: CGFloat {
        switch config.style {
        case .default:   return 8
        case .brutalist:  return 0
        case .soft:      return 12
        case .tight:     return 2
        case .ascii:     return 0
        case .cyber:     return 1
        }
    }

    // MARK: - Border Style

    static var borderWidth: CGFloat {
        config.style == .brutalist ? 2 : 1
    }

    static var borderStrokeStyle: StrokeStyle {
        if config.style == .ascii {
            return StrokeStyle(lineWidth: 1, dash: [4, 3])
        }
        return StrokeStyle(lineWidth: borderWidth)
    }

    // MARK: - Panel Shadow

    struct PanelShadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    static var panelShadow: PanelShadow {
        switch config.style {
        case .default:
            return PanelShadow(color: .black.opacity(0.6), radius: 40, x: 0, y: 8)
        case .brutalist:
            return PanelShadow(color: .black.opacity(0.35), radius: 0, x: 8, y: 8)
        case .soft:
            return PanelShadow(color: .black.opacity(0.2), radius: 32, x: 0, y: 16)
        case .tight:
            return PanelShadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
        case .ascii:
            return PanelShadow(color: .clear, radius: 0, x: 0, y: 0)
        case .cyber:
            return PanelShadow(color: accent.opacity(0.3), radius: 30, x: 0, y: 0)
        }
    }
```

PITFALL: `radiusLg`, `radiusMd`, `radiusSm` MUST be computed `static var`, NOT `static let`. They change dynamically when the user switches styles. Using `let` makes them constants that never update.

Verify: The file compiles. Theme.radiusLg returns different values for each ThemeStyle case.


Continue `Arrange/Sources/Theme.swift` — append the rest of the `Theme` enum and supporting types:

```swift
    // MARK: - Dimensions

    static let panelWidth: CGFloat     = 1060
    static let panelHeight: CGFloat    = 600
    static let sidebarWidth: CGFloat   = 260

    enum PanelSize: String, CaseIterable, Equatable {
        case sm, md, lg

        var dimensions: (width: CGFloat, height: CGFloat) {
            switch self {
            case .sm: return (720, 440)
            case .md: return (880, 520)
            case .lg: return (1060, 600)
            }
        }

        var sidebarWidth: CGFloat {
            switch self {
            case .sm: return 190
            case .md: return 220
            case .lg: return 260
            }
        }

        var fontScale: CGFloat {
            switch self {
            case .sm: return 0.85
            case .md: return 0.92
            case .lg: return 1.0
            }
        }

        var padding: CGFloat {
            switch self {
            case .sm: return 12
            case .md: return 16
            case .lg: return 20
            }
        }
    }

    static var currentPadding: CGFloat { ThemeConfig.shared.panelSize.padding }
    static var canvasPadding: CGFloat  { ThemeConfig.shared.panelSize == .sm ? 8 : 14 }
    static let seamWidth: CGFloat      = 6

    // MARK: - Fonts

    static func mainFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if config.style == .ascii { return monoFont(size, weight: weight) }
        switch config.font {
        case .grotesk:
            let name = spaceName(for: weight)
            if NSFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            return .system(size: size, weight: weight, design: .default)
        case .mono:
            return monoFont(size, weight: weight)
        case .system:
            return .system(size: size, weight: weight, design: .default)
        }
    }

    static func monoFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name = monoName(for: weight)
        if NSFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }

    private static func spaceName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:    return "SpaceGrotesk-Light"
        case .medium:   return "SpaceGrotesk-Medium"
        case .semibold: return "SpaceGrotesk-SemiBold"
        case .bold:     return "SpaceGrotesk-Bold"
        default:        return "SpaceGrotesk-Regular"
        }
    }

    private static func monoName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:    return "JetBrainsMono-Light"
        case .medium:   return "JetBrainsMono-Medium"
        case .semibold: return "JetBrainsMono-SemiBold"
        case .bold:     return "JetBrainsMono-Bold"
        default:        return "JetBrainsMono-Regular"
        }
    }

    // MARK: - App Colors

    struct AppColor {
        let bg: Color
        let text: Color
    }

    static func appColor(for bundleId: String) -> AppColor {
        let id = bundleId.lowercased()

        if id.contains("vscode") || id.contains("cursor") {
            return AppColor(bg: Color(hex: 0x1E2636), text: Color(hex: 0x7090BB))
        } else if id.contains("terminal") || id.contains("iterm") {
            return AppColor(bg: Color(hex: 0x252525), text: Color(hex: 0x888888))
        } else if id.contains("safari") {
            return AppColor(bg: Color(hex: 0x333333), text: Color(hex: 0x888888))
        } else if id.contains("slack") {
            return AppColor(bg: Color(hex: 0x2A2A2A), text: Color(hex: 0x666666))
        } else if id.contains("figma") {
            return AppColor(bg: Color(hex: 0x3D1F6B), text: Color(hex: 0xC49AFF))
        } else if id.contains("notes") {
            return AppColor(bg: Color(hex: 0x2A2A1E), text: Color(hex: 0x887744))
        } else if id.contains("spotify") {
            return AppColor(bg: Color(hex: 0x1A2A1E), text: Color(hex: 0x449944))
        } else if id.contains("messages") || id.contains("mobilesms") {
            return AppColor(bg: Color(hex: 0x1E2233), text: Color(hex: 0x5577CC))
        } else if id.contains("chrome") || id.contains("arc") {
            return AppColor(bg: Color(hex: 0x2A2533), text: Color(hex: 0x9977CC))
        } else if id.contains("mail") {
            return AppColor(bg: Color(hex: 0x1E2A33), text: Color(hex: 0x5599BB))
        } else if id.contains("xcode") {
            return AppColor(bg: Color(hex: 0x1A2636), text: Color(hex: 0x5588CC))
        } else if id.contains("finder") {
            return AppColor(bg: Color(hex: 0x1A2A33), text: Color(hex: 0x5599AA))
        } else {
            let hash = abs(bundleId.hashValue)
            let hue = Double(hash % 360) / 360.0
            return AppColor(
                bg: Color(hue: hue, saturation: 0.2, brightness: 0.15),
                text: Color(hue: hue, saturation: 0.3, brightness: 0.55)
            )
        }
    }

    // MARK: - Themed Border Modifier

    struct ThemedBorder: ViewModifier {
        var radius: CGFloat
        var color: Color?

        func body(content: Content) -> some View {
            content.overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color ?? Theme.border, style: Theme.borderStrokeStyle)
            )
        }
    }
}

// MARK: - View Extension

extension View {
    func themedBorder(radius: CGFloat = Theme.radiusMd, color: Color? = nil) -> some View {
        modifier(Theme.ThemedBorder(radius: radius, color: color))
    }
}

// MARK: - Scanline Overlay (ASCII)

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let lineCount = Int(geo.size.height / 4)
            Path { path in
                for i in 0..<lineCount {
                    let y = CGFloat(i) * 4 + 2
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.035), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Dot Grid Overlay (Cyber)

struct DotGridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let cols = Int(geo.size.width / 16) + 1
            let rows = Int(geo.size.height / 16) + 1
            Path { path in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * 16
                        let y = CGFloat(row) * 16
                        path.addEllipse(in: CGRect(x: x - 0.5, y: y - 0.5, width: 1, height: 1))
                    }
                }
            }
            .fill(Color.white.opacity(0.025))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Cyber Bracket Overlay

struct CyberBracketOverlay: View {
    var opacity: Double = 0.35

    var body: some View {
        GeometryReader { geo in
            let size: CGFloat = 10
            let inset: CGFloat = 6
            // Top-left bracket
            Path { path in
                path.move(to: CGPoint(x: inset, y: inset + size))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset + size, y: inset))
            }
            .stroke(Theme.accent.opacity(opacity), lineWidth: 1)

            // Bottom-right bracket
            Path { path in
                path.move(to: CGPoint(x: geo.size.width - inset - size, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset - size))
            }
            .stroke(Theme.accent.opacity(opacity), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
```

PITFALL: The `mainFont()` function MUST check `config.style == .ascii` first and force mono. If you check the font selector first, ASCII mode won't override to monospace.

PITFALL: Font lookup uses `NSFont(name:size:)` to check availability. If the custom font isn't registered, it silently falls back to system. This is intentional — the app works without custom fonts, they just look better with them.

Verify: Theme.mainFont(12, weight: .bold) returns a Space Grotesk font when style is `.default` and font is `.grotesk`, and a JetBrains Mono font when style is `.ascii` regardless of font selector.


### Step 10: App Delegate & Entry Point

#### `Arrange/Sources/AppDelegate.swift`

```swift
import AppKit
import SwiftUI
import HotKey

// MARK: - Floating Panel

class FloatingPanel: NSPanel {
    var onEscape: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func cancelOperation(_ sender: Any?) {
        onEscape?()
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    private var settingsWindow: NSWindow?
    private var hotKey: HotKey?
    private var sizeObservation: Any?
    let store = ArrangeStore()
    private var styleObservation: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerFonts()
        checkAccessibilityPermission()
        setupPanel()
        setupHotKey()
    }

    // MARK: - Fonts

    private func registerFonts() {
        guard let fontsURL = Bundle.main.resourceURL?.appendingPathComponent("Fonts") else { return }
        guard let enumerator = FileManager.default.enumerator(
            at: fontsURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return }

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "ttf" || fileURL.pathExtension == "otf" {
                CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, nil)
            }
        }
    }

    // MARK: - Accessibility

    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        store.hasAccessibilityPermission = trusted
        if !trusted {
            store.statusText = "Grant Accessibility permission in System Settings"
        }
    }

    // MARK: - Panel

    private func setupPanel() {
        let panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: Theme.panelWidth, height: Theme.panelHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .utilityWindow
        panel.collectionBehavior = [.fullScreenAuxiliary]

        panel.onEscape = { [weak self] in
            self?.hidePanel()
        }

        let hostingView = NSHostingView(
            rootView: PanelView(store: store, dismiss: { [weak self] in
                self?.hidePanel()
            })
        )
        hostingView.layer?.cornerRadius = Theme.radiusLg
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView

        self.panel = panel
        observePanelSize()
        observeStyle()
    }

    private func observePanelSize() {
        func observe() {
            withObservationTracking {
                _ = store.panelSize
            } onChange: { [weak self] in
                DispatchQueue.main.async {
                    self?.resizePanel()
                    self?.observePanelSize()
                }
            }
        }
        observe()
    }

    private func observeStyle() {
        func observe() {
            withObservationTracking {
                _ = ThemeConfig.shared.style
            } onChange: { [weak self] in
                DispatchQueue.main.async {
                    self?.updateCornerRadius()
                    self?.observeStyle()
                }
            }
        }
        observe()
    }

    private func updateCornerRadius() {
        guard let hostingView = panel?.contentView as? NSHostingView<PanelView> else { return }
        hostingView.layer?.cornerRadius = Theme.radiusLg
    }

    private func resizePanel() {
        guard let panel else { return }
        let dims = store.panelSize.dimensions
        let oldFrame = panel.frame
        let newX = oldFrame.midX - dims.width / 2
        let newY = oldFrame.midY - dims.height / 2
        let newFrame = NSRect(x: newX, y: newY, width: dims.width, height: dims.height)
        panel.setFrame(newFrame, display: true, animate: true)
    }

    // MARK: - HotKey

    private func setupHotKey() {
        hotKey = HotKey(key: .space, modifiers: [.option, .command])
        hotKey?.keyDownHandler = { [weak self] in
            self?.togglePanel()
        }
    }

    // MARK: - Toggle

    func togglePanel() {
        guard let panel else { return }
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        guard let panel else { return }
        recheckAccessibility()
        store.refresh()
        panel.center()
        panel.makeKeyAndOrderFront(nil)
    }

    private func recheckAccessibility() {
        store.hasAccessibilityPermission = AXIsProcessTrusted()
        if store.hasAccessibilityPermission {
            store.statusText = ""
        } else {
            store.statusText = "Grant Accessibility permission in System Settings"
        }
    }

    func hidePanel() {
        panel?.orderOut(nil)
    }

    func showSettings() {
        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Arrange Settings"
        window.center()
        window.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: SettingsView(store: store))
        window.contentView = hostingView

        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

PITFALL: `isMovableByWindowBackground` MUST be `false`. The panel has a custom `WindowDragHandle` NSViewRepresentable for dragging. If `isMovableByWindowBackground` is `true`, it intercepts ALL mouse events before SwiftUI gestures, breaking DragGesture on seams and blocks.

PITFALL: `observePanelSize()` and `observeStyle()` use `withObservationTracking` with a recursive pattern — onChange dispatches to main queue and re-registers. This is the ONLY way to observe @Observable changes from non-SwiftUI code (AppKit). Do NOT try to use Combine or NotificationCenter.

PITFALL: `hostingView.layer?.cornerRadius` must be set BOTH at creation AND re-set when style changes. The hosting view's layer clips the SwiftUI content — without this, brutalist/ASCII modes would still show the old corner radius at the NSView level.

#### `Arrange/Sources/ArrangeApp.swift`

```swift
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
```

Verify: Build succeeds. App appears as menu bar icon. ⌥⌘Space toggles floating panel.


### Step 11: Main Views — PanelView, TopBar, MonitorBar, LayoutTabsView, SettingsView

#### `Arrange/Sources/Views/PanelView.swift`

```swift
import SwiftUI

struct PanelView: View {
    @Bindable var store: ArrangeStore
    var dismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            MonitorBar(store: store)

            HStack(spacing: 0) {
                // Sidebar
                VStack(alignment: .leading, spacing: 0) {
                    WindowListView(store: store)
                    ModifyInputView(store: store)
                    ActionButtons(store: store)
                }
                .frame(width: store.panelSize.sidebarWidth)
                .padding(store.panelSize.padding)

                // Divider
                Rectangle()
                    .fill(Theme.border)
                    .frame(width: 1)
                    .if(Theme.isASCII) { $0.overlay(
                        Rectangle()
                            .stroke(Theme.border, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .frame(width: 1)
                    )}

                // Main area
                VStack(spacing: 0) {
                    LayoutTabsView(store: store)
                    CanvasView(store: store)
                    StatusLine(text: store.statusText)
                }
                .padding(store.panelSize.padding)
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: store.panelSize.dimensions.width, height: store.panelSize.dimensions.height)
        .animation(.easeInOut(duration: 0.25), value: store.panelSize)
        .background(Theme.bgPanel)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
        .themedBorder(radius: Theme.radiusLg)
        .shadow(
            color: Theme.panelShadow.color,
            radius: Theme.panelShadow.radius,
            x: Theme.panelShadow.x,
            y: Theme.panelShadow.y
        )
    }
}

// MARK: - Status Line

struct StatusLine: View {
    let text: String
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        HStack {
            Text(text)
                .font(Theme.monoFont(isSm ? 10 : 11))
                .foregroundStyle(Theme.text3)
                .lineLimit(1)
            Spacer()
        }
        .frame(minHeight: isSm ? 14 : 18)
        .padding(.top, isSm ? 8 : 16)
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
```

PITFALL: The `if` conditional view modifier MUST be defined exactly as shown. The backticks around `if` are required because it's a Swift keyword. This modifier is used throughout the app (e.g., `.if(Theme.isASCII) { ... }`).

#### `Arrange/Sources/Views/TopBar.swift`

```swift
import SwiftUI
import AppKit

// MARK: - Window Drag Handle

struct WindowDragHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> DragHandleView { DragHandleView() }
    func updateNSView(_ nsView: DragHandleView, context: Context) {}
}

class DragHandleView: NSView {
    override var mouseDownCanMoveWindow: Bool { true }
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

// MARK: - Top Bar

struct TopBar: View {
    @State private var showThemePopover = false

    var body: some View {
        HStack {
            // Brand
            HStack(spacing: 12) {
                Button(action: { showThemePopover.toggle() }) {
                    BrandIcon()
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showThemePopover, arrowEdge: .bottom) {
                    ThemePopover()
                }

                Text("ARRANGE")
                    .font(Theme.mainFont(15, weight: .bold))
                    .foregroundStyle(Theme.text1)
                    .tracking(Theme.isCyber ? 6 : 0)
            }

            Spacer()

            // Powered by
            HStack(spacing: 0) {
                Text("powered by ")
                    .font(Theme.monoFont(10))
                    .foregroundStyle(Theme.text4)
                Text("ritual.industries")
                    .font(Theme.monoFont(10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(.vertical, ThemeConfig.shared.panelSize == .sm ? 10 : 16)
        .padding(.horizontal, ThemeConfig.shared.panelSize == .sm ? 16 : 24)
        .background { WindowDragHandle() }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Brand Icon

struct BrandIcon: View {
    var body: some View {
        Canvas { context, size in
            let gap: CGFloat = 2
            let blockW = (size.width - gap) / 2
            let blockH = (size.height - gap) / 2

            context.fill(
                Path(CGRect(x: 0, y: 0, width: blockW, height: blockH)),
                with: .color(Theme.accent)
            )
            context.fill(
                Path(CGRect(x: blockW + gap, y: 0, width: blockW, height: blockH)),
                with: .color(Theme.text5)
            )
            context.fill(
                Path(CGRect(x: 0, y: blockH + gap, width: blockW, height: blockH)),
                with: .color(Theme.text5)
            )
            context.fill(
                Path(CGRect(x: blockW + gap, y: blockH + gap, width: blockW, height: blockH)),
                with: .color(Theme.bgActive)
            )
        }
        .frame(width: 24, height: 24)
    }
}

// MARK: - Theme Popover

struct ThemePopover: View {
    private let config = ThemeConfig.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Style section — 3x2 grid
            VStack(alignment: .leading, spacing: 8) {
                Text("STYLE")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                let columns = [
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4)
                ]
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(ThemeStyle.allCases, id: \.self) { style in
                        Button(action: { config.style = style }) {
                            Text(style.displayName)
                                .font(Theme.monoFont(10, weight: config.style == style ? .bold : .medium))
                                .foregroundStyle(config.style == style ? Theme.accent : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    config.style == style ? Theme.accent.opacity(0.15) : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(config.style == style ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider().opacity(0.3)

            // Font section — segmented
            VStack(alignment: .leading, spacing: 8) {
                Text("FONT")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                HStack(spacing: 0) {
                    ForEach(ThemeFont.allCases, id: \.self) { font in
                        Button(action: { config.font = font }) {
                            Text(font.displayName)
                                .font(Theme.monoFont(10, weight: config.font == font ? .bold : .medium))
                                .foregroundStyle(config.font == font ? Theme.text1 : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    config.font == font ? Theme.bgActive : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: 6))
            }

            Divider().opacity(0.3)

            // Color section
            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                HStack(spacing: 6) {
                    // Main colors
                    ForEach(ThemeColor.mainColors, id: \.self) { color in
                        ColorSwatch(color: color, isActive: config.colorChoice == color) {
                            config.colorChoice = color
                        }
                    }

                    // Separator
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 18)
                        .padding(.horizontal, 2)

                    // Special colors
                    ForEach(ThemeColor.specialColors, id: \.self) { color in
                        ColorSwatch(color: color, isActive: config.colorChoice == color) {
                            config.colorChoice = color
                        }
                    }
                }
            }

            Divider().opacity(0.3)

            // Mode toggle
            HStack {
                Text("MODE")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Spacer()

                HStack(spacing: 0) {
                    Button(action: { config.isDark = true }) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(config.isDark ? .white : .secondary)
                            .frame(width: 28, height: 24)
                            .background(config.isDark ? Theme.accent.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)

                    Button(action: { config.isDark = false }) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(!config.isDark ? .white : .secondary)
                            .frame(width: 28, height: 24)
                            .background(!config.isDark ? Theme.accent.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}

// MARK: - Color Swatch

struct ColorSwatch: View {
    let color: ThemeColor
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if color == .bw {
                    // Half black / half white
                    ZStack {
                        Circle().fill(.white)
                        HalfCircle()
                            .fill(.black)
                            .frame(width: 18, height: 18)
                    }
                } else {
                    Circle().fill(Color(hex: color.hex))
                }
            }
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .stroke(.white.opacity(isActive ? 0.8 : 0), lineWidth: 2)
                    .padding(1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Half Circle Shape

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}
```

PITFALL: `WindowDragHandle` uses `NSViewRepresentable` to bridge to AppKit. The `performDrag(with:)` method is the ONLY reliable way to enable window dragging on a borderless NSPanel in SwiftUI. Do NOT use `.onDrag` or `.gesture(DragGesture(...))` for window movement.

PITFALL: The `WindowDragHandle` is placed as `.background { WindowDragHandle() }` on the top bar. This makes the entire top bar draggable. It works because `isMovableByWindowBackground` is `false` — the NSView's `mouseDownCanMoveWindow = true` takes precedence only in the top bar area.

Verify: Panel can be dragged by the top bar. Theme popover opens when clicking the brand icon.


#### `Arrange/Sources/Views/MonitorBar.swift`

```swift
import SwiftUI

struct MonitorBar: View {
    @Bindable var store: ArrangeStore

    private var monitorLabel: String {
        Theme.isASCII ? "> DISPLAY" : "DISPLAY"
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(monitorLabel)
                .font(Theme.monoFont(10, weight: .semibold))
                .foregroundStyle(Theme.text3)
                .tracking(Theme.isCyber ? 2 : 1.5)
                .padding(.trailing, 8)

            ForEach(Array(store.screens.enumerated()), id: \.element.id) { index, screen in
                MonitorTab(
                    name: screen.name,
                    resolution: screen.resolution,
                    isActive: index == store.selectedScreenIndex
                ) {
                    store.selectedScreenIndex = index
                }
            }

            if store.screens.isEmpty {
                Text("No displays detected")
                    .font(Theme.monoFont(10))
                    .foregroundStyle(Theme.text4)
            }

            Spacer()

            HStack(spacing: 2) {
                ForEach(Theme.PanelSize.allCases, id: \.self) { size in
                    Button(action: { store.panelSize = size }) {
                        Text(size.rawValue.uppercased())
                            .font(Theme.monoFont(9, weight: .semibold))
                            .foregroundStyle(store.panelSize == size ? Theme.text1 : Theme.text4)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(
                                store.panelSize == size ? Theme.bgActive : Color.clear,
                                in: RoundedRectangle(cornerRadius: 4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, store.panelSize == .sm ? 8 : 12)
        .padding(.horizontal, store.panelSize == .sm ? 16 : 24)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Monitor Tab

struct MonitorTab: View {
    let name: String
    let resolution: String
    let isActive: Bool
    let action: () -> Void

    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Theme.accent : Theme.text5)
                    .frame(width: 6, height: 6)

                Text(name)
                    .font(Theme.mainFont(isSm ? 11 : 12, weight: .semibold))
                    .foregroundStyle(isActive ? Theme.text1 : Theme.text3)
                    .lineLimit(1)

                if !isSm {
                    Text(resolution)
                        .font(Theme.monoFont(9))
                        .foregroundStyle(Theme.text4)
                }
            }
            .padding(.vertical, isSm ? 6 : 8)
            .padding(.horizontal, isSm ? 10 : 16)
            .background(
                isActive ? Theme.bgActive : Color.clear,
                in: RoundedRectangle(cornerRadius: Theme.radiusSm)
            )
        }
        .buttonStyle(.plain)
    }
}
```

#### `Arrange/Sources/Views/LayoutTabsView.swift`

```swift
import SwiftUI

struct LayoutTabsView: View {
    @Bindable var store: ArrangeStore
    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 2 : 4) {
            ForEach(Array(store.availablePresets.enumerated()), id: \.element.id) { index, preset in
                LayoutTab(
                    name: preset.name,
                    isActive: index == store.selectedPresetIndex
                ) {
                    store.selectPreset(at: index)
                }
            }

            Spacer()

            Button(action: { store.resetPreset() }) {
                Text("Reset")
                    .font(Theme.monoFont(isSm ? 9 : 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                    .tracking(0.5)
            }
            .buttonStyle(.plain)
            .padding(.vertical, isSm ? 5 : 7)
            .padding(.horizontal, isSm ? 8 : 12)
            .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusSm))
            .themedBorder(radius: Theme.radiusSm)
        }
        .padding(.bottom, isSm ? 8 : 14)
    }
}

// MARK: - Layout Tab

struct LayoutTab: View {
    let name: String
    let isActive: Bool
    let action: () -> Void
    private var isSm: Bool { ThemeConfig.shared.panelSize == .sm }

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(Theme.mainFont(isSm ? 10 : 11, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.text3)
                .padding(.vertical, isSm ? 5 : 7)
                .padding(.horizontal, isSm ? 8 : 14)
                .background(
                    isActive ? Theme.bgActive : Color.clear,
                    in: RoundedRectangle(cornerRadius: Theme.radiusSm)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusSm)
                        .stroke(isActive ? Theme.borderActive : Color.clear, style: Theme.borderStrokeStyle)
                )
        }
        .buttonStyle(.plain)
    }
}
```

#### `Arrange/Sources/Views/SettingsView.swift`

```swift
import SwiftUI

struct SettingsView: View {
    @Bindable var store: ArrangeStore
    @State private var keyText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Claude API Key")
                .font(.headline)

            SecureField("sk-ant-...", text: $keyText)
                .textFieldStyle(.roundedBorder)

            Text("Used for natural language layout modification. Get a key at console.anthropic.com.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Save") {
                    store.apiKey = keyText
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            Text("Accessibility Permission")
                .font(.headline)

            HStack(spacing: 12) {
                Circle()
                    .fill(store.hasAccessibilityPermission ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(store.hasAccessibilityPermission ? "Granted" : "Not granted")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            Text("If Arrange already appears as approved but isn't working, select it in the list, press the minus (−) button to remove it, enter your password if prompted, then press the plus (+) button and re-add Arrange from your Applications folder.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            keyText = store.apiKey
        }
    }
}
```

Verify: All 5 files compile. Panel shows top bar with drag handle, monitor bar with display tabs and size toggle, layout tabs with Reset button.


### Step 12: Canvas Views — CanvasView, AppBlockView, SeamView

#### `Arrange/Sources/Views/Canvas/CanvasView.swift`

```swift
import SwiftUI

struct CanvasView: View {
    @Bindable var store: ArrangeStore

    var body: some View {
        GeometryReader { geo in
            let preset = store.currentPreset
            let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
            let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * Theme.seamWidth
            let availableWidth = geo.size.width - totalVSeams
            let blockFrames = Self.computeBlockFrames(canvasSize: geo.size, preset: preset)

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(Array(preset.columns.enumerated()), id: \.offset) { colIndex, column in
                        let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)

                        columnView(
                            column: column,
                            colIndex: colIndex,
                            totalHeight: geo.size.height,
                            blockPositions: blockFrames
                        )
                        .frame(width: colWidth)

                        // Vertical seam between columns
                        if colIndex < preset.columns.count - 1 {
                            SeamView(
                                orientation: .vertical,
                                store: store,
                                col: colIndex,
                                app: 0,
                                totalSize: availableWidth,
                                totalFlex: totalColFlex
                            )
                        }
                    }
                }

                // Floating ghost block follows cursor during drag
                if store.isDragging,
                   let pos = store.dragPosition,
                   let source = store.dragSource,
                   let sourceBlock = blockFrames.first(where: { $0.col == source.col && $0.app == source.app }) {
                    DragGhostView(store: store, col: source.col, app: source.app)
                        .frame(width: sourceBlock.frame.width * 0.85, height: sourceBlock.frame.height * 0.85)
                        .position(x: pos.x, y: pos.y)
                        .allowsHitTesting(false)
                }
            }
        }
        .coordinateSpace(name: "canvas")
        .padding(Theme.canvasPadding)
        .frame(maxHeight: .infinity)
        .background(Theme.bgCanvas, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
        .themedBorder(radius: Theme.radiusMd)
        .overlay {
            if Theme.isASCII {
                ScanlineOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    .allowsHitTesting(false)
            } else if Theme.isCyber {
                DotGridOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private func columnView(column: LayoutPreset.Column, colIndex: Int, totalHeight: CGFloat, blockPositions: [BlockPosition]) -> some View {
        let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
        let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * Theme.seamWidth
        let availableHeight = totalHeight - totalHSeams

        VStack(spacing: 0) {
            ForEach(Array(column.apps.enumerated()), id: \.offset) { appIndex, app in
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)

                AppBlockView(
                    store: store,
                    col: colIndex,
                    app: appIndex,
                    blockPositions: blockPositions
                )
                .frame(height: appHeight)

                // Horizontal seam between apps
                if appIndex < column.apps.count - 1 {
                    SeamView(
                        orientation: .horizontal,
                        store: store,
                        col: colIndex,
                        app: appIndex,
                        totalSize: availableHeight,
                        totalFlex: totalAppFlex
                    )
                }
            }
        }
    }

    // Compute block frames mathematically from flex values instead of using preferences
    static func computeBlockFrames(canvasSize: CGSize, preset: LayoutPreset) -> [BlockPosition] {
        let totalColFlex = preset.columns.reduce(0.0) { $0 + $1.flex }
        let totalVSeams = CGFloat(max(0, preset.columns.count - 1)) * Theme.seamWidth
        let availableWidth = canvasSize.width - totalVSeams

        var positions: [BlockPosition] = []
        var xOffset: CGFloat = 0

        for (colIndex, column) in preset.columns.enumerated() {
            let colWidth = availableWidth * CGFloat(column.flex / totalColFlex)
            let totalAppFlex = column.apps.reduce(0.0) { $0 + $1.flex }
            let totalHSeams = CGFloat(max(0, column.apps.count - 1)) * Theme.seamWidth
            let availableHeight = canvasSize.height - totalHSeams

            var yOffset: CGFloat = 0

            for (appIndex, app) in column.apps.enumerated() {
                let appHeight = availableHeight * CGFloat(app.flex / totalAppFlex)
                positions.append(BlockPosition(
                    col: colIndex,
                    app: appIndex,
                    frame: CGRect(x: xOffset, y: yOffset, width: colWidth, height: appHeight)
                ))
                yOffset += appHeight + Theme.seamWidth
            }

            xOffset += colWidth + Theme.seamWidth
        }

        return positions
    }
}
```

PITFALL: Block positions MUST be computed mathematically via `computeBlockFrames()`. Do NOT use SwiftUI PreferenceKey to report frames — this causes infinite render loops because the preference update triggers a layout pass which triggers another preference update.

PITFALL: The DragGhostView must have `.allowsHitTesting(false)` — otherwise it intercepts the drag gesture and the drop target never gets hit.

#### `Arrange/Sources/Views/Canvas/AppBlockView.swift`

```swift
import SwiftUI

struct AppBlockView: View {
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int
    let blockPositions: [BlockPosition]

    @State private var justSwapped = false
    @State private var isHovered = false

    private var window: WindowInfo? {
        store.windowFor(col: col, app: app)
    }

    private var accent: AccentLevel {
        store.accentLevel(col: col, app: app)
    }

    private var bgColor: Color {
        switch accent {
        case .primary:   return Theme.accent
        case .secondary: return Theme.accentDark
        case .none:
            if let w = window {
                return Theme.appColor(for: w.bundleId).bg
            }
            return Theme.bgSurface
        }
    }

    private var textColor: Color {
        switch accent {
        case .primary, .secondary: return .white
        case .none:
            if let w = window {
                return Theme.appColor(for: w.bundleId).text
            }
            return Theme.text4
        }
    }

    private var displayName: String {
        let name = window?.displayName ?? "Empty"
        if Theme.isASCII || Theme.isCyber { return name.uppercased() }
        return name
    }

    private var isDropTarget: Bool {
        store.dropTarget?.col == col && store.dropTarget?.app == app
    }

    private var shouldDesaturate: Bool {
        accent == .none && (Theme.isGrey || Theme.isBW)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(bgColor)

            Text(displayName)
                .font(Theme.mainFont(Theme.isASCII ? 11 : 12, weight: .semibold))
                .foregroundStyle(textColor)
                .tracking(Theme.isASCII ? 2 : (Theme.isCyber ? 3 : 0))
                .lineLimit(1)
        }
        .saturation(shouldDesaturate ? 0 : 1)
        .contrast(shouldDesaturate && Theme.isBW ? 1.4 : 1)
        .opacity(store.isDragging && store.dragSource?.col == col && store.dragSource?.app == app ? 0.25 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(isDropTarget ? Theme.accent : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isDropTarget ? Theme.accent.opacity(0.3) : .clear,
            radius: isDropTarget ? 10 : 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(justSwapped ? Theme.accent : Color.clear, lineWidth: 2)
                .shadow(color: justSwapped ? Theme.accent.opacity(0.5) : .clear, radius: 12)
        )
        .overlay {
            if Theme.isCyber {
                CyberBracketOverlay(opacity: isHovered ? 0.8 : 0.35)
            }
        }
        .if(Theme.isASCII) { $0.themedBorder(radius: Theme.radiusMd, color: Theme.borderActive) }
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .highPriorityGesture(dragGesture)
    }

    // MARK: - Drag Gesture

    private var sourceFrame: CGRect? {
        blockPositions.first(where: { $0.col == col && $0.app == app })?.frame
    }

    private func canvasPoint(from value: DragGesture.Value) -> CGPoint? {
        guard let origin = sourceFrame?.origin else { return nil }
        return CGPoint(
            x: origin.x + value.location.x,
            y: origin.y + value.location.y
        )
    }

    private func hitTest(_ point: CGPoint) -> (col: Int, app: Int)? {
        for pos in blockPositions {
            if pos.frame.contains(point) && (pos.col != col || pos.app != app) {
                return (col: pos.col, app: pos.app)
            }
        }
        return nil
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if !store.isDragging {
                    store.isDragging = true
                    store.dragSource = (col: col, app: app)
                }
                guard let point = canvasPoint(from: value) else { return }
                store.dragPosition = point
                store.dropTarget = hitTest(point)
            }
            .onEnded { value in
                // Compute drop target from final position directly
                let target: (col: Int, app: Int)?
                if let point = canvasPoint(from: value) {
                    target = hitTest(point)
                } else {
                    target = store.dropTarget
                }

                if let source = store.dragSource, let target = target {
                    store.swapBlocks(from: source, to: target)
                    justSwapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        justSwapped = false
                    }
                }
                store.isDragging = false
                store.dragSource = nil
                store.dropTarget = nil
                store.dragPosition = nil
            }
    }
}

// MARK: - Drag Ghost

struct DragGhostView: View {
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int

    private var window: WindowInfo? {
        store.windowFor(col: col, app: app)
    }

    private var bgColor: Color {
        if let w = window {
            return Theme.appColor(for: w.bundleId).bg
        }
        return Theme.bgSurface
    }

    private var displayName: String {
        window?.displayName ?? "Empty"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .fill(bgColor)
            Text(displayName)
                .font(Theme.mainFont(11, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .opacity(0.85)
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }
}

// MARK: - Block Position

struct BlockPosition: Equatable {
    let col: Int
    let app: Int
    let frame: CGRect
}
```

PITFALL: `.highPriorityGesture(dragGesture)` is REQUIRED, not `.gesture(dragGesture)`. Without highPriority, the WindowDragHandle in the top bar can steal events. This manifests as blocks being undraggable intermittently.

PITFALL: The drag gesture uses `canvasPoint(from:)` to convert from block-local coordinates to canvas coordinates. `DragGesture.Value.location` is relative to the view the gesture is attached to (the block), NOT the canvas. You must add the block's origin from `blockPositions` to get the canvas-space point.

PITFALL: In `.onEnded`, you MUST recompute the drop target from the final `value.location`, NOT just use `store.dropTarget`. The `.onChanged` handler may not fire for the exact final position, causing missed drops.


#### `Arrange/Sources/Views/Canvas/SeamView.swift`

```swift
import SwiftUI

enum SeamOrientation {
    case vertical
    case horizontal
}

struct SeamView: View {
    let orientation: SeamOrientation
    @Bindable var store: ArrangeStore
    let col: Int
    let app: Int
    let totalSize: CGFloat
    let totalFlex: Double

    @State private var isHovered = false
    @State private var isActive = false

    var body: some View {
        Group {
            switch orientation {
            case .vertical:
                verticalSeam
            case .horizontal:
                horizontalSeam
            }
        }
    }

    // MARK: - Vertical Seam

    private var verticalSeam: some View {
        Color.clear
            .frame(width: Theme.seamWidth)
            .contentShape(Rectangle())
            .overlay {
                RoundedRectangle(cornerRadius: 1)
                    .fill(isHovered || isActive ? Theme.accent : Theme.text5)
                    .frame(width: 2, height: 36)
            }
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        if !isActive {
                            isActive = true
                            store.beginSeamDrag()
                        }
                        let pixelsPerFlex = totalSize / CGFloat(totalFlex)
                        let flexDelta = Double(value.translation.width) / Double(pixelsPerFlex)
                        store.adjustColumnFlex(leftCol: col, delta: flexDelta)
                    }
                    .onEnded { _ in
                        isActive = false
                        store.endSeamDrag()
                    }
            )
    }

    // MARK: - Horizontal Seam

    private var horizontalSeam: some View {
        Color.clear
            .frame(height: Theme.seamWidth)
            .contentShape(Rectangle())
            .overlay {
                RoundedRectangle(cornerRadius: 1)
                    .fill(isHovered || isActive ? Theme.accent : Theme.text5)
                    .frame(width: 36, height: 2)
            }
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        if !isActive {
                            isActive = true
                            store.beginSeamDrag()
                        }
                        let pixelsPerFlex = totalSize / CGFloat(totalFlex)
                        let flexDelta = Double(value.translation.height) / Double(pixelsPerFlex)
                        store.adjustAppFlex(col: col, aboveApp: app, delta: flexDelta)
                    }
                    .onEnded { _ in
                        isActive = false
                        store.endSeamDrag()
                    }
            )
    }
}
```

PITFALL: Seam drag uses `value.translation` which is CUMULATIVE from drag start. The `beginSeamDrag()` takes a snapshot of the original flex values, and `adjustColumnFlex`/`adjustAppFlex` always compute from `snapshot + delta`. If you apply deltas incrementally (delta from last frame), the values compound and the seam moves exponentially. This was the hardest bug to fix.

Verify: Seam handles appear between blocks. Dragging a seam resizes adjacent columns/rows proportionally. Cursor changes to resize arrows on hover.

### Step 13: Sidebar Views — WindowListView, ActionButtons, ModifyInputView

#### `Arrange/Sources/Views/Sidebar/WindowListView.swift`

```swift
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
```

#### `Arrange/Sources/Views/Sidebar/ActionButtons.swift`

```swift
import SwiftUI

struct ActionButtons: View {
    @Bindable var store: ArrangeStore

    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        HStack(spacing: isSm ? 6 : 8) {
            // Undo button
            Button(action: { store.undo() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: isSm ? 10 : 11, weight: .semibold))
                    Text("Undo")
                        .font(Theme.mainFont(isSm ? 11 : 12, weight: .semibold))
                }
                .foregroundStyle(Theme.text2)
                .padding(.vertical, isSm ? 8 : 12)
                .padding(.horizontal, isSm ? 12 : 18)
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
                .themedBorder(radius: Theme.radiusMd)
            }
            .buttonStyle(.plain)

            // Apply button
            Button(action: { store.apply() }) {
                HStack(spacing: 4) {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text(store.isLoading ? "Working..." : "Apply")
                        .font(Theme.mainFont(isSm ? 11 : 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isSm ? 8 : 12)
                .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.radiusMd))
            }
            .buttonStyle(.plain)
            .disabled(store.isLoading)
        }
    }
}
```

#### `Arrange/Sources/Views/Sidebar/ModifyInputView.swift`

```swift
import SwiftUI

struct ModifyInputView: View {
    @Bindable var store: ArrangeStore

    private var isSm: Bool { store.panelSize == .sm }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel("MODIFY")

            TextField("", text: $store.modifyText, prompt: Text("e.g. make VS Code larger").foregroundStyle(Theme.placeholder))
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
```

Verify: Sidebar shows window list with colored dot indicators, modify text field, and undo/apply buttons. Apply button uses accent color. All themed borders update when style changes.


## IMPORTANT CONSTRAINTS

These are anti-patterns and constraints learned through iteration. A fresh Claude MUST follow these to avoid re-discovering the same bugs.

1. **DO NOT use `static let` for theme-dependent dimensions.** `radiusLg`, `radiusMd`, `radiusSm`, `borderWidth`, `seamWidth`, `canvasPadding` — all must be `static var` computed properties that read from `ThemeConfig.shared.style`. Using `let` means they're computed once at launch and never update when the user changes style.

2. **DO NOT use PreferenceKey to collect block frames in CanvasView.** SwiftUI PreferenceKeys trigger re-renders when values change, which causes an infinite render loop when multiple blocks report geometry simultaneously. Instead, compute block frames mathematically from flex values using `computeBlockFrames()`.

3. **DO NOT set `isMovableByWindowBackground = true` on the NSPanel.** This conflicts with DragGesture on the canvas. Blocks become undraggable because macOS intercepts the mouse events for window dragging. Use a dedicated `WindowDragHandle` NSViewRepresentable with `mouseDownCanMoveWindow` and `performDrag` on the top bar only.

4. **DO NOT use ObservableObject / @StateObject / @Published.** The entire app uses the Swift 5.9 `@Observable` macro with `@Bindable` for bindings. Mixing the two observation systems causes silent failures where views don't update.

5. **DO NOT use `@EnvironmentObject` to pass the store.** Pass `ArrangeStore` as a direct property with `@Bindable var store: ArrangeStore`. The `@Observable` macro doesn't work with `@EnvironmentObject`.

6. **DO NOT use SwiftUI's `onDrag` / `onDrop` for block reordering.** macOS `onDrag` requires NSItemProvider and UTTypes, adds unwanted system drag visuals, and doesn't give enough control over the ghost view appearance. Use raw `DragGesture` with manual hit testing and a custom floating ghost overlay.

7. **DO NOT use `Color(nsColor:)` for hex color initialization.** Create a `Color(hex:)` extension that parses the hex string directly. The NSColor route introduces color space conversion issues that cause subtle color mismatches.

8. **DO NOT use `.onAppear` to register bundled fonts.** Fonts must be registered at `applicationDidFinishLaunching` time using `CTFontManagerRegisterFontsForURL`. If registered lazily, SwiftUI may cache the font lookup failure and never retry, resulting in fallback to system font permanently.

9. **DO NOT use `NSCursor.set()` for seam hover cursors.** Use `NSCursor.push()` on hover enter and `NSCursor.pop()` on hover exit. `set()` doesn't properly restore the previous cursor when the mouse leaves the seam.

10. **DO NOT store the `DragGesture` snapshot on the view's `@State`.** Store it on the `ArrangeStore` (`seamDragSnapshot`). The seam drag uses the gesture's cumulative `.translation` relative to a snapshot of the original flex values taken at drag start. If the snapshot is lost or reset mid-drag, the seam jumps erratically.

11. **DO NOT use `.gesture()` for block drag.** Use `.highPriorityGesture()`. Without `highPriority`, the seam's `DragGesture` on adjacent views can steal the gesture from app blocks.

12. **DO NOT use SwiftUI coordinate spaces for drag hit testing.** `DragGesture.Value.location` is in the LOCAL coordinate space of the block being dragged, NOT the canvas. Convert to canvas coordinates by adding the block's origin (from `blockPositions`). Failing to do this makes the ghost appear in the wrong position and drop targets never match.

13. **DO NOT rely on `store.dropTarget` in `DragGesture.onEnded`.** The `dropTarget` may be stale if the last `onChanged` didn't fire for the final position. Always recompute the hit test from `value.location` in `onEnded` for reliable drops.

14. **DO NOT use `NSFont.init(name:size:)` alone to check font availability.** Some fonts register successfully but return nil from NSFont init. Use `CTFontManagerRegisterFontsForURL` and trust the registration succeeded. For the font selector (grotesk/mono/system), use fallback chains: try the custom font, fall back to a system alternative.

15. **DO NOT add the `.xcodeproj` to git.** The project uses xcodegen with `project.yml`. The Makefile runs `xcodegen generate` before building. Committing `.xcodeproj` causes merge conflicts and stale project state.

16. **DO NOT use `@main struct App: App` with a `WindowGroup`.** This is a menu-bar-only app (`LSUIElement: true`). The main entry point uses `MenuBarExtra` for the tray icon. The floating panel is a manually managed `NSPanel` created in `AppDelegate`, not a SwiftUI `Window` or `WindowGroup`.

17. **DO NOT use `Task { @MainActor in }` for delayed UI work after drag ends.** Use `DispatchQueue.main.asyncAfter(deadline:)` for the swap flash animation timing. The `@MainActor` `Task` doesn't guarantee the exact timing needed for the 0.5s flash.

18. **The `if` conditional modifier requires backtick escaping.** Because `if` is a Swift keyword, the View extension method must be declared as `` func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View ``. Call site: `.if(Theme.isASCII) { ... }`.

## Design Specifications

### Colors — Dark Mode

| Token | Hex | Usage |
|-------|-----|-------|
| bgPanel | #1A1A1E | Panel background |
| bgCanvas | #111113 | Canvas area background |
| bgSurface | #232328 | Input fields, button backgrounds |
| text1 | #FFFFFF | Primary text |
| text2 | #D1D1D6 | Secondary text |
| text3 | #A0A0AB | Tertiary text |
| text4 | #72727E | Quaternary text |
| text5 | #3A3A44 | Quinary text (seam indicators, faint UI) |
| border | #2A2A32 | Default borders |
| borderActive | #3A3A44 | Active/hover borders |
| inputBorder | #2A2A32 | Input field borders |
| placeholder | #4A4A55 | Placeholder text |
| divider | #2A2A32 | Dividers |
| shadow | #000000 @ 30% | Drop shadows |

### Colors — Light Mode (Warm-toned)

| Token | Hex | Usage |
|-------|-----|-------|
| bgPanel | #FAF7F2 | Panel background (warm cream) |
| bgCanvas | #F0EDE6 | Canvas area background (warm) |
| bgSurface | #FFFFFF | Input fields, button backgrounds |
| text1 | #1A1A1E | Primary text |
| text2 | #3A3A44 | Secondary text |
| text3 | #6A6A77 | Tertiary text |
| text4 | #9A9AAB | Quaternary text |
| text5 | #D1D1D6 | Quinary text |
| border | #E0DDD6 | Default borders |
| borderActive | #C8C5BE | Active/hover borders |
| inputBorder | #E0DDD6 | Input field borders |
| placeholder | #B0ADA6 | Placeholder text |
| divider | #E0DDD6 | Dividers |
| shadow | #000000 @ 8% | Drop shadows |

### Accent Colors

| Name | Accent | Hover | Dark |
|------|--------|-------|------|
| Red | #E53935 | #EF5350 | #C62828 |
| Orange | #E85002 | #FF6010 | #C13A00 |
| Amber | #F59E0B | #FBBF24 | #D97706 |
| Green | #43A047 | #56B85A | #2E7D32 |
| Teal | #0D9488 | #14B8A6 | #0F766E |
| Cyan | #00BCD4 | #22D0E8 | #0097A7 |
| Blue | #2196F3 | #42A5F5 | #1565C0 |
| Violet | #8B5CF6 | #A078FF | #6A3AC8 |
| Rose | #E91E63 | #F06292 | #C2185B |
| Grey | #888888 | #999999 | #666666 |
| B&W | white(dark)/black(light) | — | — |

Grey mode: Apply `.saturation(0)` to non-accent app blocks.
B&W mode: Apply `.saturation(0).contrast(1.4)` to non-accent blocks. Accent = white in dark mode, black in light mode.

### App Block Colors (per bundleId)

These are deterministic colors assigned to each app based on its bundle ID. The mapping uses a hash of the bundle ID string to select from a palette of 12 color pairs (bg + text):

```
(bg: #2D1B3D, text: #C4A6E0)  // Purple
(bg: #1B2D3D, text: #A6C4E0)  // Blue
(bg: #1B3D2D, text: #A6E0C4)  // Teal
(bg: #3D2D1B, text: #E0C4A6)  // Orange
(bg: #3D1B2D, text: #E0A6C4)  // Pink
(bg: #2D3D1B, text: #C4E0A6)  // Lime
(bg: #1B2D2D, text: #A6D4D4)  // Cyan
(bg: #3D1B1B, text: #E0A6A6)  // Red
(bg: #2D2D1B, text: #D4D4A6)  // Yellow
(bg: #1B1B3D, text: #A6A6E0)  // Indigo
(bg: #2D1B2D, text: #C4A6C4)  // Mauve
(bg: #1B3D3D, text: #A6E0E0)  // Aqua
```

Selection: `abs(bundleId.hashValue) % 12`

### Fonts

| Selector | Primary | Fallback |
|----------|---------|----------|
| Grotesk | Space Grotesk | .systemFont |
| Mono | JetBrains Mono | .monospacedSystemFont |
| System | .systemFont | — |

- Bundled font files: `SpaceGrotesk-Regular.ttf`, `SpaceGrotesk-Bold.ttf`, `JetBrainsMono-Regular.ttf`, `JetBrainsMono-Bold.ttf`
- Registered at launch via `CTFontManagerRegisterFontsForURL`
- ASCII style forces Mono regardless of font selector
- Default weight mapping: `.regular` → Regular, `.medium`/`.semibold`/`.bold` → Bold

### Style Dimensions

| Style | radiusLg | radiusMd | radiusSm | borderWidth |
|-------|----------|----------|----------|-------------|
| Default | 20 | 10 | 8 | 1 |
| Brutalist | 0 | 0 | 0 | 2 |
| Soft | 28 | 16 | 12 | 1 |
| Tight | 4 | 3 | 2 | 1 |
| ASCII | 0 | 0 | 0 | 1 |
| Cyber | 2 | 2 | 1 | 1 |

### Style Shadows

| Style | Shadow |
|-------|--------|
| Default | color: shadow, radius: 12, y: 4 |
| Brutalist | color: black @ 50%, radius: 0, x: 8, y: 8 |
| Soft | color: shadow, radius: 30, y: 8 |
| Tight | color: shadow, radius: 6, y: 2 |
| ASCII | none |
| Cyber | color: accent @ 10%, radius: 20, y: 0 |

### Panel Sizes

| Size | Width | Height |
|------|-------|--------|
| sm | 440 | 320 |
| md | 580 | 380 |
| lg | 700 | 450 |

### Spacing

- Canvas padding: 12
- Sidebar width: 200 (220 for lg)
- Seam width: 12
- Divider height: 1px (dashed for ASCII)
- Section label font size: 10 (sm: 9)
- Main font sizes: 11-14 depending on context and panel size
- Button padding: vertical 9-13, horizontal 12-18

### Animations

- Swap flash: 2px accent stroke + glow for 0.5s, then removed via `DispatchQueue.main.asyncAfter`
- Drag ghost: 85% scale of source block, 85% opacity, shadow(black 40%, radius 12, y 4)
- Drop target: 2px accent stroke + accent glow (radius 10)
- Seam hover indicator: instant color change from text5 to accent
- Theme transitions: `.animation(.easeInOut(duration: 0.2), value: themeConfig.style)` on PanelView
- No other animations — all layout changes are instant

## Known Pitfalls & Workarounds

1. **Infinite render loop with PreferenceKey block frames**: If you use a GeometryReader + PreferenceKey inside each AppBlockView to report its frame to the parent CanvasView, SwiftUI enters an infinite layout loop because updating the preference triggers a re-render which triggers a new geometry read.
   **Fix**: Compute all block frames mathematically in `CanvasView.computeBlockFrames()` using the same flex arithmetic as the layout. Pass the resulting `[BlockPosition]` array down to each `AppBlockView`.
   **Why**: SwiftUI preference propagation happens during the render pass. Updating state from preferences causes another render, which produces new preferences, ad infinitum.

2. **DragGesture coordinates are block-local**: `DragGesture.Value.location` returns the cursor position relative to the dragged view's own coordinate space, NOT the parent canvas. If you use `location` directly for hit testing, the ghost appears offset and drops never match their targets.
   **Fix**: In `canvasPoint(from:)`, add the block's origin from `blockPositions` (the mathematically computed frames) to `value.location`. This converts to canvas-space coordinates: `CGPoint(x: origin.x + value.location.x, y: origin.y + value.location.y)`.
   **Why**: SwiftUI DragGesture doesn't have a built-in way to get coordinates in a named coordinate space. The `coordinateSpace` parameter only works for the `startLocation`, not `location`.

3. **Drop target stale in onEnded**: `store.dropTarget` may not reflect the final cursor position because `onChanged` doesn't always fire for the very last drag position before the finger lifts.
   **Fix**: In `DragGesture.onEnded`, recompute the hit test from `value` (the final drag value) instead of reading `store.dropTarget`. Use `store.dropTarget` only as a fallback if `canvasPoint` returns nil.
   **Why**: macOS coalesces drag events. The last `onChanged` may have fired 10+ points before the actual release position.

4. **Seam drag jumps with incremental deltas**: If you compute the flex delta incrementally (adding each onChanged's translation delta to the current flex), rounding errors accumulate and the seam drifts away from the cursor over time.
   **Fix**: Use a snapshot pattern. On drag start (`beginSeamDrag()`), save the entire current preset as `seamDragSnapshot`. On each `onChanged`, compute the flex delta from the TOTAL `value.translation` (which is cumulative from drag start) and apply it to the SNAPSHOT values, not the current values.
   **Why**: `DragGesture.Value.translation` is cumulative from drag start, not incremental from last event.

5. **NSPanel steals DragGesture from canvas blocks**: With `isMovableByWindowBackground = true`, macOS intercepts mouse-down events on the panel background for window dragging, preventing DragGesture from firing on canvas blocks.
   **Fix**: Set `isMovableByWindowBackground = false` on the NSPanel. Create a `WindowDragHandle` NSViewRepresentable that returns `true` from `mouseDownCanMoveWindow` and calls `window?.performDrag(with:)` in `mouseDown`. Place this handle only on the top bar.
   **Why**: `isMovableByWindowBackground` applies to the entire window. There's no SwiftUI-native way to limit it to a specific region.

6. **Bundled fonts not available if registered lazily**: If you defer font registration to `onAppear` or a SwiftUI view's init, SwiftUI may attempt to resolve the font before registration completes. SwiftUI caches failed font lookups and never retries, so the app permanently falls back to the system font.
   **Fix**: Register all bundled fonts in `AppDelegate.applicationDidFinishLaunching` using `CTFontManagerRegisterFontsForURL` with `.process` scope, BEFORE creating any SwiftUI views.
   **Why**: SwiftUI resolves fonts at view creation time and caches the result. The cache is not invalidated when new fonts are registered.

7. **Hosting view corner radius doesn't update on style change**: The NSHostingView's root view is created once. If the panel's `cornerRadius` is set only at creation time, changing from Default (radius 20) to Brutalist (radius 0) won't update the panel's visual corners.
   **Fix**: Use `withObservationTracking` in a recursive closure pattern to observe `ThemeConfig.shared.style`. On each change, update both `panel.cornerRadius` and the hosting view layer's `cornerRadius`.
   **Why**: NSHostingView doesn't automatically bridge @Observable changes to NSView-level properties.

8. **`.gesture()` loses to adjacent seam gestures**: If an AppBlockView uses `.gesture(dragGesture)`, the adjacent SeamView's DragGesture can steal the gesture because SwiftUI's gesture resolution is ambiguous when two gesture-bearing views share an edge.
   **Fix**: Use `.highPriorityGesture(dragGesture)` on AppBlockView. This ensures the block's drag always wins over the seam's drag when the gesture starts on the block.
   **Why**: SwiftUI's default gesture priority is FIFO by view hierarchy. `highPriorityGesture` explicitly wins ties.

9. **DragGhostView intercepts hit testing**: If the floating ghost view during drag is hit-testable, it blocks the `onChanged` hit testing for drop targets underneath it, so blocks directly under the cursor never become drop targets.
   **Fix**: Apply `.allowsHitTesting(false)` to the `DragGhostView` in CanvasView.
   **Why**: SwiftUI's hit testing respects the view hierarchy. The ghost is rendered on top, so it receives hit tests first.

10. **`if` is a Swift reserved keyword**: Creating a View extension method named `if` for conditional modifiers will fail to compile without backtick escaping.
    **Fix**: Declare as `` func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View `` and call as `.if(condition) { ... }` (call site doesn't need backticks).
    **Why**: Swift requires backticks to use reserved keywords as identifiers in declarations.

11. **NSCursor.set() doesn't restore properly**: Using `NSCursor.set()` for the resize cursor on seam hover leaves the resize cursor active even after the mouse exits the seam.
    **Fix**: Use `NSCursor.push()` on hover enter and `NSCursor.pop()` on hover exit. The push/pop stack ensures proper restoration.
    **Why**: `set()` replaces the current cursor without saving the previous one. `push()`/`pop()` maintain a stack.

12. **HotKey package must use 0.2.1+**: Earlier versions of `soffes/HotKey` don't support macOS 14 properly and can crash on key registration.
    **Fix**: Pin to `.upToNextMajor(from: "0.2.1")` in project.yml.
    **Why**: API changes in macOS 14's event tap system.

13. **xcodegen must run before every build**: The `.xcodeproj` is not committed. If you run `xcodebuild` without first running `xcodegen generate`, it will fail with "project not found."
    **Fix**: The Makefile always runs `xcodegen generate` as the first step of `make build`. Never bypass this.
    **Why**: xcodegen generates `.xcodeproj` from `project.yml`. It's gitignored to avoid merge conflicts.

14. **`xattr -cr .` is required after xcodegen**: xcodegen-generated files sometimes get quarantine extended attributes on macOS that cause code signing to fail with "resource fork, Finder information, or similar detritus not allowed."
    **Fix**: Run `xattr -cr .` after `xcodegen generate` and before `xcodebuild`. The Makefile does this automatically.
    **Why**: macOS quarantine system flags files created by non-sandboxed tools.

## Self-Review Checklist

After generating all files, review your output against this checklist:

- [ ] `make build` compiles without errors (xcodegen → xattr → xcodebuild → codesign)
- [ ] App appears as menu bar icon only (no Dock icon, LSUIElement: true)
- [ ] ⌥⌘Space toggles the floating panel
- [ ] Panel floats above all windows (.floating level, .nonactivatingPanel)
- [ ] Panel is draggable by the top bar area only, not by the canvas
- [ ] Clicking the brand icon opens the theme popover with 4 sections: Style (3×2 grid), Font (segmented), Color (9 + separator + Grey/B&W), Mode (toggle)
- [ ] Changing style updates corner radii, border styles, and shadows instantly
- [ ] ASCII style: all fonts mono, dashed borders, scanline overlay on canvas, "// " prefix on section labels, "> " prefix on monitor label, uppercase app block text with 2px tracking
- [ ] Cyber style: corner bracket decorations on app blocks, dot grid overlay on canvas, accent glow shadow, uppercase text with 3px tracking
- [ ] Brutalist style: zero radii, 2px solid borders, hard offset shadow
- [ ] Changing color updates accent throughout (buttons, active tabs, seam highlights, drop targets)
- [ ] Grey color: non-accent app blocks are desaturated
- [ ] B&W color: non-accent blocks desaturated + high contrast, accent = white (dark) / black (light)
- [ ] Dark/light mode toggle works; light mode uses warm tones (#FAF7F2 panel background)
- [ ] Theme settings persist across app relaunch (UserDefaults)
- [ ] Panel size (sm/md/lg) changes panel dimensions and adjusts font sizes / padding
- [ ] Monitor bar shows all connected displays with correct names
- [ ] Layout tabs show presets for current window count (regenerate on refresh)
- [ ] Canvas shows columns and apps with correct flex-proportional sizing
- [ ] Seam drag resizes adjacent columns/apps smoothly without jumping
- [ ] Block drag shows ghost at 85% scale, highlights drop target, swaps windows on release
- [ ] Block swap only changes window assignments, not grid layout
- [ ] Apply button moves windows to their computed screen frames
- [ ] Undo restores window positions (if windows were moved) or layout (if only layout changed)
- [ ] Claude modify sends preset to API and applies returned modification
- [ ] Settings window has API key field and accessibility permission status
- [ ] Accessibility permission check shows correct state with instructions to fix
- [ ] All 25 source files are present with correct directory structure
- [ ] All 4 bundled font files are present in Resources/Fonts/
- [ ] project.yml has correct targets, dependencies, and build settings
- [ ] Makefile has clean, generate, build, install targets in correct order
- [ ] .gitignore excludes .xcodeproj, build/, DerivedData/, .DS_Store
