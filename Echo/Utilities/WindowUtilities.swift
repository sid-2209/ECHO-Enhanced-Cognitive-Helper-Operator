import SwiftUI
import AppKit

class WindowUtilities {
    static func configureWindow(_ window: NSWindow) {
        window.styleMask = [.resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .floating

        // Set initial size (expanded)
        let initialWidth: CGFloat = 350 // chat (300) + sidebar (50)
        let initialHeight: CGFloat = 500
        window.setContentSize(NSSize(width: initialWidth, height: initialHeight))

        // Set minimum size to new compact requirements
        window.minSize = NSSize(width: 50, height: 300)  // collapsed: 50px, expanded: 300+50=350px minimum
        window.maxSize = NSSize(width: 600, height: 800)

        // Position window at bottom-right corner
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = NSRect(
                x: screenFrame.maxX - initialWidth - 20,
                y: screenFrame.minY + 20,
                width: initialWidth,
                height: initialHeight
            )
            window.setFrame(windowFrame, display: true)
        }

        // Restore position and collapse state from UserDefaults
        restoreWindowPosition(window)
        restoreCollapseState(window)
    }

    static func updateWindowSize(_ window: NSWindow, isCollapsed: Bool) {
        let newWidth: CGFloat = isCollapsed ? 50 : 350

        // Add slight delay to better coordinate with SwiftUI animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            var newFrame = window.frame
            newFrame.size.width = newWidth

            // Adjust x position to keep right edge in same place
            newFrame.origin.x = window.frame.maxX - newWidth

            // Use custom timing to match SwiftUI easeInOut animation
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.animator().setFrame(newFrame, display: true)
            }
        }

        // Save collapse state
        UserDefaults.standard.set(isCollapsed, forKey: "WindowIsCollapsed")
    }

    static func getCollapseState() -> Bool {
        return UserDefaults.standard.bool(forKey: "WindowIsCollapsed")
    }

    private static func restoreCollapseState(_ window: NSWindow) {
        let isCollapsed = getCollapseState()
        if isCollapsed {
            updateWindowSize(window, isCollapsed: true)
        }
    }

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