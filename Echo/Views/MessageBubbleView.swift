import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    private var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack {
            if isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 2) {
                // Message content
                Text(message.content ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(messageTextColor)
                    .padding(.horizontal, isUser ? 10 : 8)
                    .padding(.vertical, 6)
                    .background(messageBubbleColor)
                    .clipShape(messageBubbleShape)
                    .textSelection(.enabled)

                // Timestamp
                Text(message.timestamp ?? Date(), style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
                    .padding(.horizontal, isUser ? 10 : 4)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
        .transition(.opacity.combined(with: .move(edge: isUser ? .trailing : .leading)))
    }

    private var messageTextColor: Color {
        isUser ? .blue : .primary
    }

    private var messageBubbleColor: Color {
        isUser ? Color.blue.opacity(0.06) : Color.secondary.opacity(0.08)
    }

    private var messageBubbleShape: some Shape {
        RoundedRectangle(
            cornerRadius: 12,
            style: .continuous
        )
    }
}

struct WelcomeView: View {
    let onPromptTapped: (String) -> Void

    private let examplePrompts = [
        "Explain quantum computing simply",
        "Write a Python function to sort a list",
        "Help me debug this code",
        "What's the weather like today?"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ask me anything...")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(examplePrompts, id: \.self) { prompt in
                    Button(action: {
                        onPromptTapped(prompt)
                    }) {
                        Text(prompt)
                            .font(.system(size: 13))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
    }
}

struct ExamplePrompt: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(.secondary.opacity(0.5))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
    }
}

struct CommandHintView: View {
    let command: String
    let description: String

    var body: some View {
        HStack(spacing: 8) {
            Text(command)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.blue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.blue.opacity(0.1))
                )

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

struct TypingIndicator: View {
    @State private var animatingDots = [false, false, false]

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 4, height: 4)
                        .scaleEffect(animatingDots[index] ? 1.2 : 0.8)
                        .opacity(animatingDots[index] ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animatingDots[index]
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .onAppear {
            for index in 0..<3 {
                animatingDots[index] = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        // User message
        MessageBubbleView(message: {
            let message = Message()
            message.content = "Hello Echo! Can you help me with **markdown** formatting and `code blocks`?"
            message.role = "user"
            message.timestamp = Date()
            return message
        }())

        // AI message
        MessageBubbleView(message: {
            let message = Message()
            message.content = """
            Of course! I can help you with markdown formatting. Here are some examples:

            **Bold text** and *italic text*

            ```swift
            func greet() {
                print("Hello, World!")
            }
            ```

            I can also help with lists, links, and more!
            """
            message.role = "assistant"
            message.timestamp = Date()
            return message
        }())

        TypingIndicator()
    }
    .padding()
    .frame(width: 280)
}