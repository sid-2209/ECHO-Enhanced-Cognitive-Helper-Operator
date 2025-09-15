//
//  EchoApp.swift
//  Echo
//
//  Created by sid on 14/09/25.
//

import SwiftUI
import AppKit

@main
struct EchoApp: App {
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    configureWindow()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 330, height: 500)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            EmptyView()
        }
    }

    private func configureWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApp.windows.first {
                WindowManager.shared.setWindow(window)
                WindowManager.shared.hideWindow() // Start hidden
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Initialize menu bar controller
        MenuBarController.shared

        // Register global hotkey
        HotKeyManager.shared.registerGlobalHotKey()

        // Setup UserDefaults
        setupDefaultPreferences()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowManager.shared.showWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        HotKeyManager.shared.unregisterGlobalHotKey()
    }

    private func setupDefaultPreferences() {
        let defaults: [String: Any] = [
            "AlwaysOnTop": false,
            "WindowOriginX": 0.0,
            "WindowOriginY": 0.0
        ]

        UserDefaults.standard.register(defaults: defaults)
    }
}
