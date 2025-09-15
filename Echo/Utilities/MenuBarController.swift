import AppKit
import SwiftUI

class MenuBarController: NSObject {
    static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var window: NSWindow?
    private var isWindowVisible = false

    override init() {
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "waveform.circle", accessibilityDescription: "Echo")
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }
    }

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            toggleWindow()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        let showMenuItem = NSMenuItem(title: "Show Echo", action: #selector(showWindow), keyEquivalent: "e")
        showMenuItem.keyEquivalentModifierMask = [.command, .shift]
        showMenuItem.target = self
        menu.addItem(showMenuItem)

        let hideMenuItem = NSMenuItem(title: "Hide Echo", action: #selector(hideWindow), keyEquivalent: "")
        hideMenuItem.target = self
        menu.addItem(hideMenuItem)

        menu.addItem(NSMenuItem.separator())

        let alwaysOnTopMenuItem = NSMenuItem(title: "Always on Top", action: #selector(toggleAlwaysOnTop), keyEquivalent: "")
        alwaysOnTopMenuItem.target = self
        alwaysOnTopMenuItem.state = UserDefaults.standard.bool(forKey: "AlwaysOnTop") ? .on : .off
        menu.addItem(alwaysOnTopMenuItem)

        menu.addItem(NSMenuItem.separator())

        let preferencesMenuItem = NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        preferencesMenuItem.keyEquivalentModifierMask = .command
        preferencesMenuItem.target = self
        menu.addItem(preferencesMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem(title: "Quit Echo", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.keyEquivalentModifierMask = .command
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)

        statusItem?.popUpMenu(menu)
    }

    @objc private func showWindow() {
        WindowManager.shared.showWindow()
    }

    @objc private func hideWindow() {
        WindowManager.shared.hideWindow()
    }

    @objc private func toggleWindow() {
        WindowManager.shared.toggleWindow()
    }

    @objc private func toggleAlwaysOnTop() {
        let currentState = UserDefaults.standard.bool(forKey: "AlwaysOnTop")
        UserDefaults.standard.set(!currentState, forKey: "AlwaysOnTop")
        WindowManager.shared.updateWindowLevel()
    }

    @objc private func showPreferences() {
        // TODO: Implement preferences window
        print("Show preferences")
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}