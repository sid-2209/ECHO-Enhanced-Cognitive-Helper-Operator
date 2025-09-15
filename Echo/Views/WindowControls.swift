import SwiftUI
import AppKit

struct WindowControls: View {
    @State private var isCollapsed = false
    @State private var opacity: Double = WindowUtilities.getWindowOpacity()

    var body: some View {
        HStack {
            // Drag handle
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 30, height: 4)
                .cornerRadius(2)
                .onHover { isHovering in
                    NSCursor.openHand.push()
                    if !isHovering {
                        NSCursor.pop()
                    }
                }

            Spacer()

            HStack(spacing: 8) {
                // Opacity control
                Button(action: {
                    opacity = opacity > 0.7 ? 0.5 : (opacity > 0.5 ? 1.0 : 0.7)
                    WindowUtilities.saveWindowOpacity(opacity)
                    updateWindowOpacity()
                }) {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Adjust opacity")

                // Minimize/expand toggle
                Button(action: {
                    isCollapsed.toggle()
                    resizeWindow()
                }) {
                    Image(systemName: isCollapsed ? "plus.circle" : "minus.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help(isCollapsed ? "Expand" : "Minimize")

                // Close button
                Button(action: {
                    NSApp.hide(nil)
                }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Hide Echo")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
    }

    private func updateWindowOpacity() {
        if let window = NSApp.windows.first {
            window.alphaValue = opacity
        }
    }

    private func resizeWindow() {
        guard let window = NSApp.windows.first else { return }

        let newSize = isCollapsed ?
            NSSize(width: 60, height: 60) :
            NSSize(width: 350, height: 500)

        window.setContentSize(newSize)

        if isCollapsed {
            window.styleMask.remove(.resizable)
        } else {
            window.styleMask.insert(.resizable)
        }
    }
}

#Preview {
    WindowControls()
}