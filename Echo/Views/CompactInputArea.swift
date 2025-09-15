import SwiftUI
import AppKit

struct CompactInputArea: View {
    @Binding var messageText: String
    @Binding var showCommandSuggestions: Bool
    @Binding var commandSuggestions: [ChatCommand]
    @Binding var droppedImages: [NSImage]
    let sendMessage: () -> Void
    let handleCommand: (String) -> Void

    @State private var isInputFocused: Bool = false
    @State private var inputHeight: CGFloat = 36
    @State private var selectedCommandIndex = 0

    private let maxInputHeight: CGFloat = 144 // 4 lines

    var hasContent: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Command suggestions overlay (minimal floating palette)
            if showCommandSuggestions && !commandSuggestions.isEmpty {
                MinimalCommandPalette(
                    suggestions: commandSuggestions,
                    selectedIndex: selectedCommandIndex,
                    onSelect: { command in
                        messageText = command.command
                        showCommandSuggestions = false
                        handleCommand(command.command)
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(1)
            }

            // Dropped images preview
            if !droppedImages.isEmpty {
                CompactImagePreview(images: $droppedImages)
                    .transition(.move(edge: .bottom))
            }

            // Input field with integrated buttons (Claude.ai style)
            HStack(spacing: 0) {
                // Paperclip icon (inside input field, left side)
                Button(action: selectImage) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.7))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Attach image")

                // Text input (expandable)
                CompactTextEditor(
                    text: $messageText,
                    height: $inputHeight,
                    maxHeight: maxInputHeight,
                    placeholder: messageText.isEmpty ? "Ask anything..." : "",
                    isFocused: $isInputFocused,
                    onSubmit: {
                        if hasContent {
                            sendMessage()
                        }
                    }
                )
                .onChange(of: messageText) { oldValue, newValue in
                    handleTextChange(newValue)
                }
                .onKeyPress { keyPress in
                    handleKeyPress(keyPress)
                }

                // Send button (inside input field, right side, only when text exists)
                if hasContent {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(.blue)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Send message (⌘↵)")
                    .padding(.trailing, 6)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .frame(height: max(36, inputHeight))
            .background(
                RoundedRectangle(cornerRadius: 18) // Pill shape
                    .stroke(strokeColor, lineWidth: strokeWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(backgroundColor)
                    )
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: showCommandSuggestions)
        .animation(.easeInOut(duration: 0.2), value: hasContent)
        .animation(.easeInOut(duration: 0.15), value: isInputFocused)
    }

    // Dynamic styling based on focus state
    private var strokeColor: Color {
        if isInputFocused {
            return .blue.opacity(0.3)
        }
        return .secondary.opacity(0.2)
    }

    private var strokeWidth: CGFloat {
        isInputFocused ? 1.5 : 1.0
    }

    private var backgroundColor: Color {
        Color.secondary.opacity(0.05)
    }

    private var shadowColor: Color {
        isInputFocused ? .blue.opacity(0.1) : .clear
    }

    private var shadowRadius: CGFloat {
        isInputFocused ? 4 : 0
    }

    private func handleTextChange(_ newValue: String) {
        if newValue.hasPrefix("/") && newValue.count > 1 {
            let query = String(newValue.dropFirst()).lowercased()
            let filtered = ChatCommand.allCommands.filter { command in
                command.command.lowercased().contains(query) ||
                command.description.lowercased().contains(query)
            }.prefix(5) // Only show top 5 commands
            commandSuggestions = Array(filtered)
            showCommandSuggestions = !commandSuggestions.isEmpty
            selectedCommandIndex = 0
        } else {
            showCommandSuggestions = false
            commandSuggestions = []
        }
    }

    private func handleKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
        if showCommandSuggestions {
            switch keyPress.key {
            case .upArrow:
                selectedCommandIndex = max(0, selectedCommandIndex - 1)
                return .handled
            case .downArrow:
                selectedCommandIndex = min(commandSuggestions.count - 1, selectedCommandIndex + 1)
                return .handled
            case .tab, .return:
                if selectedCommandIndex < commandSuggestions.count {
                    let command = commandSuggestions[selectedCommandIndex]
                    messageText = command.command
                    showCommandSuggestions = false
                    handleCommand(command.command)
                    return .handled
                }
            case .escape:
                showCommandSuggestions = false
                return .handled
            default:
                break
            }
        }

        // Handle Cmd+Enter for sending
        if keyPress.modifiers.contains(.command) && keyPress.key == .return {
            if hasContent {
                sendMessage()
                return .handled
            }
        }

        return .ignored
    }

    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff, .bmp]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                if let image = NSImage(contentsOf: url) {
                    droppedImages.append(image)
                }
            }
        }
    }
}

struct CompactTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    let maxHeight: CGFloat
    let placeholder: String
    @Binding var isFocused: Bool
    let onSubmit: () -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()

        // Configure text view
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = NSColor.clear
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.lineFragmentPadding = 4

        // Configure scroll view
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = NSColor.clear

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.string != text {
            textView.string = text
        }

        // Update height
        let contentHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 36
        let newHeight = min(max(36, contentHeight + 16), maxHeight)
        if abs(height - newHeight) > 1 {
            DispatchQueue.main.async {
                height = newHeight
            }
        }

        // Update focus state
        let isCurrentlyFocused = textView.window?.firstResponder == textView
        if isFocused != isCurrentlyFocused {
            DispatchQueue.main.async {
                isFocused = isCurrentlyFocused
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: CompactTextEditor

        init(_ parent: CompactTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) &&
               NSEvent.modifierFlags.contains(.command) {
                parent.onSubmit()
                return true
            }
            return false
        }
    }
}

#Preview {
    CompactInputArea(
        messageText: .constant(""),
        showCommandSuggestions: .constant(false),
        commandSuggestions: .constant([]),
        droppedImages: .constant([]),
        sendMessage: {},
        handleCommand: { _ in }
    )
    .frame(width: 300)
}