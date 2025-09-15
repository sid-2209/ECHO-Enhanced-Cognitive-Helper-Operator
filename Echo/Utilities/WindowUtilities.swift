import SwiftUI
import AppKit

class WindowUtilities {
    static func configureWindow(_ window: NSWindow) {
        window.styleMask = [.fullSizeContentView] // REMOVED .resizable - prevents size interference
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .floating

        // REMOVED: All window size constraints - SwiftUI handles sizing internally
        // Set fixed window size to prevent OS-level resizing during animation
        let fixedWidth: CGFloat = 350 // Maximum width (expanded state)
        let fixedHeight: CGFloat = 500
        window.setContentSize(NSSize(width: fixedWidth, height: fixedHeight))

        // CRITICAL: No min/max size constraints - prevents OS window resizing

        // Position window at bottom-right corner
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = NSRect(
                x: screenFrame.maxX - fixedWidth - 20,
                y: screenFrame.minY + 20,
                width: fixedWidth,
                height: fixedHeight
            )
            window.setFrame(windowFrame, display: true)
        }

        // Restore position from UserDefaults (collapse state handled by SwiftUI)
        restoreWindowPosition(window)
    }

    // REMOVED: updateWindowSize() - SwiftUI handles all animations now

    static func getCollapseState() -> Bool {
        return UserDefaults.standard.bool(forKey: "WindowIsCollapsed")
    }

    // REMOVED: restoreCollapseState() - SwiftUI state management handles this

    static func saveWindowPosition(_ window: NSWindow) {
        let origin = window.frame.origin
        UserDefaults.standard.set(origin.x, forKey: "WindowOriginX")
        UserDefaults.standard.set(origin.y, forKey: "WindowOriginY")
    }

    static func restoreWindowPosition(_ window: NSWindow) {
        let x = UserDefaults.standard.double(forKey: "WindowOriginX")
        let y = UserDefaults.standard.double(forKey: "WindowOriginY")

        if x != 0 || y != 0 {
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    static func getWindowOpacity() -> Double {
        return UserDefaults.standard.double(forKey: "WindowOpacity") == 0 ? 0.95 : UserDefaults.standard.double(forKey: "WindowOpacity")
    }

    static func saveWindowOpacity(_ opacity: Double) {
        UserDefaults.standard.set(opacity, forKey: "WindowOpacity")
    }
}