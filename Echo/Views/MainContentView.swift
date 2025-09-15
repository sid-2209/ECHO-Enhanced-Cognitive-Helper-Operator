import SwiftUI
import CoreData

// Simple message model for non-Core Data storage
struct SimpleMessage: Identifiable {
    let id = UUID()
    let content: String
    let role: String // "user" or "assistant"
    let timestamp: Date
}

// Simple message bubble component
struct MessageBubbleSimple: View {
    let message: SimpleMessage

    private var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack {
            if isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .font(.system(size: 13))
                    .foregroundColor(messageTextColor)
                    .padding(.horizontal, isUser ? 10 : 8)
                    .padding(.vertical, 6)
                    .background(messageBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(message.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
                    .padding(.horizontal, isUser ? 10 : 4)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
    }

    private var messageTextColor: Color {
        isUser ? .blue : .primary
    }

    private var messageBubbleColor: Color {
        isUser ? Color.blue.opacity(0.06) : Color.secondary.opacity(0.08)
    }
}

struct MainContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var windowManager = WindowManager.shared
    @State private var isCollapsed = WindowUtilities.getCollapseState()
    @State private var opacity: Double = WindowUtilities.getWindowOpacity()
    @State private var selectedModel = "Claude Sonnet"
    @State private var selectedSection: SidebarSection = .chat
    @State private var window: NSWindow?

    // Input area state
    @State private var messageText = ""
    @State private var showCommandSuggestions = false
    @State private var commandSuggestions: [ChatCommand] = []
    @State private var droppedImages: [NSImage] = []

    // Simple message storage
    @State private var messages: [SimpleMessage] = []

    private let chatWidth: CGFloat = 300  // Updated to match requirements
    private let sidebarWidth: CGFloat = 50

    var totalWidth: CGFloat {
        isCollapsed ? sidebarWidth : chatWidth + sidebarWidth
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Chat Window
            if !isCollapsed {
                VStack(spacing: 0) {
                    // Model badge at top
                    HStack {
                        Spacer()
                        Text(selectedModel)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.orange.opacity(0.08))
                            )
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Messages area
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            if messages.isEmpty {
                                VStack(spacing: 8) {
                                    Text("Welcome to Echo!")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                        .padding()

                                    Text("Start a conversation...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            } else {
                                ForEach(messages) { message in
                                    MessageBubbleSimple(message: message)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }

                    // Functional input area
                    CompactInputArea(
                        messageText: $messageText,
                        showCommandSuggestions: $showCommandSuggestions,
                        commandSuggestions: $commandSuggestions,
                        droppedImages: $droppedImages,
                        sendMessage: sendMessage,
                        handleCommand: handleCommand
                    )
                }
                .frame(width: chatWidth)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))

                // Separator (thinner)
                Rectangle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 0.5)
                    .transition(.opacity)
            }

            // Right Panel - Sidebar
            Sidebar(
                isCollapsed: $isCollapsed,
                selectedSection: $selectedSection,
                selectedModel: $selectedModel
            )
            .frame(width: sidebarWidth)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity * 0.9)

                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)

                WindowAccessor(window: $window)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(width: totalWidth, height: 500)
        .animation(.easeInOut(duration: 0.3), value: isCollapsed)
        .onChange(of: isCollapsed) { oldValue, newValue in
            // Update window size when collapse state changes
            if let window = NSApp.windows.first {
                WindowUtilities.updateWindowSize(window, isCollapsed: newValue)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UpdateOpacity"))) { notification in
            if let newOpacity = notification.object as? Double {
                opacity = newOpacity
            }
        }
        .onChange(of: window) { oldValue, newWindow in
            if let window = newWindow {
                WindowManager.shared.setWindow(window)

                // Handle window close events
                NotificationCenter.default.addObserver(
                    forName: NSWindow.willCloseNotification,
                    object: window,
                    queue: .main
                ) { _ in
                    WindowManager.shared.hideWindow()
                }
            }
        }
        .draggableWindow()
    }

    // MARK: - Message Handling Functions

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Create user message
        let userMessage = SimpleMessage(
            content: trimmedMessage,
            role: "user",
            timestamp: Date()
        )

        // Add to messages with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(userMessage)
        }

        // Clear input
        messageText = ""

        // Simulate AI response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiResponse = SimpleMessage(
                content: "I understand your message: \"\(trimmedMessage)\". This is a simulated response from \(selectedModel).",
                role: "assistant",
                timestamp: Date()
            )

            withAnimation(.easeInOut(duration: 0.3)) {
                messages.append(aiResponse)
            }
        }
    }

    private func handleCommand(_ command: String) {
        let cmd = command.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        switch cmd {
        case "/clear":
            withAnimation(.easeInOut(duration: 0.3)) {
                messages.removeAll()
            }
        case "/new", "/reset":
            withAnimation(.easeInOut(duration: 0.3)) {
                messages.removeAll()
            }
        case "/claude", "/sonnet":
            selectedModel = "Claude Sonnet"
        case "/gpt4":
            selectedModel = "GPT-4"
        case "/gpt4o":
            selectedModel = "GPT-4o"
        case "/ollama":
            selectedModel = "Ollama"
        default:
            // Treat unknown commands as regular messages
            sendMessage()
        }
    }
}

enum SidebarSection: CaseIterable {
    case chat
    case model
    case history
    case settings

    var icon: String {
        switch self {
        case .chat: return "plus.circle"
        case .model: return "cpu"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        }
    }

    var title: String {
        switch self {
        case .chat: return "New Chat"
        case .model: return "Model"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    MainContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}