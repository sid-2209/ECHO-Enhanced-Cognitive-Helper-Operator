import SwiftUI
import AppKit

struct DraggableWindow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DragView())
    }
}

struct DragView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = DragNSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

class DragNSView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if let window = window {
            WindowUtilities.saveWindowPosition(window)
        }
    }
}

extension View {
    func draggableWindow() -> some View {
        modifier(DraggableWindow())
    }
}