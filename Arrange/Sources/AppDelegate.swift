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
