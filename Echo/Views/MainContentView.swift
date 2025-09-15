import SwiftUI
import CoreData


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

    // Core Data integration
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.updatedAt, ascending: false)],
        animation: .default)
    private var conversations: FetchedResults<Conversation>

    @State private var isTyping = false

    private let chatWidth: CGFloat = 300  // Updated to match requirements
    private let sidebarWidth: CGFloat = 50

    var currentConversation: Conversation? {
        conversations.first
    }

    var totalWidth: CGFloat {
        isCollapsed ? sidebarWidth : chatWidth + sidebarWidth
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Chat Window
            if !isCollapsed {
                VStack(spacing: 0) {
                    // Header with proper Echo branding
                    ChatHeader(selectedModel: selectedModel, isCollapsed: $isCollapsed)

                    // Messages area with improved layout and spacing
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 12) { // Increased: better spacing between messages
                                // Top breathing room
                                Spacer(minLength: 8)

                                if let conversation = currentConversation,
                                   let messages = conversation.messages?.allObjects as? [Message] {
                                    let sortedMessages = messages.sorted {
                                        ($0.timestamp ?? Date()) < ($1.timestamp ?? Date())
                                    }

                                    ForEach(sortedMessages, id: \.id) { message in
                                        MessageBubbleView(message: message)
                                            .id(message.id)
                                            .padding(.horizontal, 4) // Subtle horizontal breathing room for message bubbles
                                    }
                                } else {
                                    // Welcome state with proper padding
                                    WelcomeView(onPromptTapped: { prompt in
                                        messageText = prompt
                                    })
                                    .padding(.horizontal, 8) // Additional padding for welcome content
                                }

                                // Typing indicator with proper spacing
                                if isTyping {
                                    TypingIndicator()
                                        .padding(.horizontal, 4)
                                        .padding(.top, 4) // Small gap above typing indicator
                                }

                                // Bottom breathing room before input area
                                Spacer(minLength: 12)
                            }
                            .padding(.horizontal, 12) // Increased: proper margins around content
                            .padding(.vertical, 8)    // Increased: better top/bottom padding
                        }
                        .onChange(of: currentConversation?.messages?.count) { _ in
                            if let conversation = currentConversation,
                               let messages = conversation.messages?.allObjects as? [Message],
                               let lastMessage = messages.sorted(by: {
                                   ($0.timestamp ?? Date()) < ($1.timestamp ?? Date())
                               }).last {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: UnitPoint.bottom)
                                    }
                                }
                            }
                        }
                    }

                    // Input area with proper spacing separation
                    CompactInputArea(
                        messageText: $messageText,
                        showCommandSuggestions: $showCommandSuggestions,
                        commandSuggestions: $commandSuggestions,
                        droppedImages: $droppedImages,
                        sendMessage: sendMessage,
                        handleCommand: handleCommand
                    )
                    .padding(.top, 8) // Added: separation between messages and input area
                }
                .frame(width: chatWidth)

                // Separator (thinner)
                Rectangle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 0.5)
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
        .clipped() // CRITICAL: Ensure content is clipped to frame bounds
        .animation(.easeInOut(duration: 0.3), value: isCollapsed)
        .onChange(of: isCollapsed) { oldValue, newValue in
            // Save collapse state to UserDefaults for persistence
            UserDefaults.standard.set(newValue, forKey: "WindowIsCollapsed")
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StartNewConversation"))) { _ in
            startNewConversation()
        }
        .draggableWindow()
    }

    // MARK: - Message Handling Functions

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check for commands
        if trimmedMessage.hasPrefix("/") {
            handleCommand(trimmedMessage)
            messageText = ""
            return
        }

        withAnimation {
            let conversation = getCurrentConversation()

            // Create user message
            let userMessage = Message(context: viewContext)
            userMessage.id = UUID()
            userMessage.content = trimmedMessage
            userMessage.role = "user"
            userMessage.timestamp = Date()
            userMessage.conversation = conversation

            // Update conversation
            conversation.updatedAt = Date()

            do {
                try viewContext.save()
                isTyping = true

                // Simulate AI response (replace with actual AI integration later)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    simulateAIResponse(for: conversation)
                }
            } catch {
                print("Failed to save message: \(error)")
            }

            messageText = ""
        }
    }

    private func handleCommand(_ command: String) {
        let cmd = command.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        switch cmd {
        case "/end":
            startNewConversation()
        case "/clear":
            clearCurrentConversation()
        case "/claude", "/sonnet":
            switchModel("Claude Sonnet")
        case "/gpt4":
            switchModel("GPT-4")
        case "/gpt4o":
            switchModel("GPT-4o")
        case "/ollama":
            switchModel("Ollama")
        case "/screenshot", "/ss":
            captureScreenshot()
        case "/export":
            exportConversation()
        default:
            break
        }
    }

    private func getCurrentConversation() -> Conversation {
        if let existingConversation = conversations.first {
            return existingConversation
        }

        let newConversation = Conversation(context: viewContext)
        newConversation.id = UUID()
        newConversation.title = "New Chat"
        newConversation.createdAt = Date()
        newConversation.updatedAt = Date()

        return newConversation
    }

    private func startNewConversation() {
        // Clear current conversation or create new one
        getCurrentConversation()
    }

    private func clearCurrentConversation() {
        if let conversation = currentConversation,
           let messages = conversation.messages?.allObjects as? [Message] {
            for message in messages {
                viewContext.delete(message)
            }

            do {
                try viewContext.save()
            } catch {
                print("Failed to clear conversation: \(error)")
            }
        }
    }

    private func switchModel(_ model: String) {
        selectedModel = model
        startNewConversation()
    }

    private func captureScreenshot() {
        // TODO: Implement screenshot capture
        print("Capturing screenshot...")
    }

    private func exportConversation() {
        // TODO: Implement conversation export
        print("Exporting conversation...")
    }

    private func simulateAIResponse(for conversation: Conversation) {
        let aiMessage = Message(context: viewContext)
        aiMessage.id = UUID()
        aiMessage.content = "This is a simulated response from \(selectedModel). I understand your message and I'm here to help!"
        aiMessage.role = "assistant"
        aiMessage.timestamp = Date()
        aiMessage.conversation = conversation

        conversation.updatedAt = Date()

        do {
            try viewContext.save()
            isTyping = false
        } catch {
            print("Failed to save AI response: \(error)")
            isTyping = false
        }
    }
}

enum SidebarSection: CaseIterable {
    case chat
    case model
    case settings

    var icon: String {
        switch self {
        case .chat: return "plus.circle"
        case .model: return "cpu"
        case .settings: return "gearshape"
        }
    }

    var title: String {
        switch self {
        case .chat: return "New Chat"
        case .model: return "Model"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    MainContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}