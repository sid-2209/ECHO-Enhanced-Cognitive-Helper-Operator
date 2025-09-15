import SwiftUI
import CoreData

struct ChatPanel: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isCollapsed: Bool
    @Binding var selectedModel: String
    @State private var messageText = ""
    @State private var showCommandSuggestions = false
    @State private var commandSuggestions: [ChatCommand] = []
    @State private var isTyping = false
    @State private var droppedImages: [NSImage] = []
    @State private var isDragging = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.updatedAt, ascending: false)],
        animation: .default)
    private var conversations: FetchedResults<Conversation>

    var currentConversation: Conversation? {
        conversations.first
    }

    var body: some View {
        VStack(spacing: 0) {
            messagesArea
            inputArea
        }
        .background(Color.clear)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StartNewConversation"))) { _ in
            startNewConversation()
        }
    }

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    modelBadgeSection
                    messagesSection
                    typingIndicatorSection
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
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
        .background(messagesBackground)
        .onDrop(of: ["public.image"], isTargeted: $isDragging) { providers in
            handleImageDrop(providers: providers)
            return true
        }
    }

    private var modelBadgeSection: some View {
        HStack {
            Spacer()
            ModelBadge(modelName: selectedModel)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var messagesSection: some View {
        if let conversation = currentConversation,
           let messages = conversation.messages?.allObjects as? [Message] {
            let sortedMessages = messages.sorted {
                ($0.timestamp ?? Date()) < ($1.timestamp ?? Date())
            }

            ForEach(sortedMessages, id: \.id) { message in
                MessageBubbleView(message: message)
                    .id(message.id)
            }
        } else {
            WelcomeView(onPromptTapped: { prompt in
                messageText = prompt
            })
        }
    }

    @ViewBuilder
    private var typingIndicatorSection: some View {
        if isTyping {
            TypingIndicator()
        }
    }

    private var messagesBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(isDragging ? Color.blue : Color.clear, lineWidth: 2)
            .background(
                isDragging ?
                Color.blue.opacity(0.1) :
                Color.clear
            )
    }

    private var inputArea: some View {
        CompactInputArea(
            messageText: $messageText,
            showCommandSuggestions: $showCommandSuggestions,
            commandSuggestions: $commandSuggestions,
            droppedImages: $droppedImages,
            sendMessage: sendMessage,
            handleCommand: handleCommand
        )
    }



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


    private func handleImageDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.image") {
                provider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                    if let url = item as? URL,
                       let image = NSImage(contentsOf: url) {
                        DispatchQueue.main.async {
                            droppedImages.append(image)
                        }
                    }
                }
            }
        }
        return true
    }
}

#Preview {
    ChatPanel(
        isCollapsed: .constant(false),
        selectedModel: .constant("Claude Sonnet")
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .frame(width: 300, height: 500)
}