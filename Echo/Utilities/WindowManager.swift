import AppKit
import SwiftUI

class WindowManager: ObservableObject {
    static let shared = WindowManager()

    @Published var isWindowVisible = false
    private var window: NSWindow?

    private init() {
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidClose),
            name: NSWindow.didMiniaturizeNotification,
            object: nil
        )
    }

    func setWindow(_ window: NSWindow) {
        self.window = window
        configureWindow()
        positionWindowInitially()
    }

    private func configureWindow() {
        guard let window = window else { return }

        window.level = UserDefaults.standard.bool(forKey: "AlwaysOnTop") ? .floating : .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.hasShadow = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask = [.borderless, .resizable]
        window.isOpaque = false

        window.setContentSize(NSSize(width: 330, height: 500))
        window.minSize = NSSize(width: 280, height: 400)
        window.maxSize = NSSize(width: 600, height: 800)

        restoreWindowPosition()
    }

    private func positionWindowInitially() {
        guard let window = window, let screen = NSScreen.main else { return }

        let savedPosition = getSavedWindowPosition()
        if savedPosition != NSZeroPoint {
            window.setFrameOrigin(savedPosition)
        } else {
            let screenFrame = screen.visibleFrame
            let windowSize = window.frame.size
            let x = screenFrame.maxX - windowSize.width - 20
            let y = screenFrame.minY + 60
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    func showWindow() {
        guard let window = window else { return }

        if !isWindowVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            isWindowVisible = true
        }
    }

    func hideWindow() {
        guard let window = window else { return }

        if isWindowVisible {
            saveWindowPosition()
            window.orderOut(nil)
            isWindowVisible = false
        }
    }

    func toggleWindow() {
        if isWindowVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }

    func updateWindowLevel() {
        guard let window = window else { return }
        let alwaysOnTop = UserDefaults.standard.bool(forKey: "AlwaysOnTop")
        window.level = alwaysOnTop ? .floating : .normal
    }

    private func saveWindowPosition() {
        guard let window = window else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set(origin.x, forKey: "WindowOriginX")
        UserDefaults.standard.set(origin.y, forKey: "WindowOriginY")
    }

    private func restoreWindowPosition() {
        guard let window = window else { return }
        let savedPosition = getSavedWindowPosition()
        if savedPosition != NSZeroPoint {
            window.setFrameOrigin(savedPosition)
        }
    }

    private func getSavedWindowPosition() -> NSPoint {
        let x = UserDefaults.standard.double(forKey: "WindowOriginX")
        let y = UserDefaults.standard.double(forKey: "WindowOriginY")
        return NSPoint(x: x, y: y)
    }

    @objc private func windowDidClose() {
        isWindowVisible = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}