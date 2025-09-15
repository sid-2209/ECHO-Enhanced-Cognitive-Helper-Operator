import SwiftUI
import CoreData

struct ChatHistoryView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.updatedAt, ascending: false)],
        animation: .default)
    private var conversations: FetchedResults<Conversation>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Chat History")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // History list
            if conversations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No chat history")
                        .font(.title3)
                    Text("Start a conversation to see it here")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(conversations, id: \.id) { conversation in
                            ConversationRow(conversation: conversation) {
                                // Load conversation when selected
                                isPresented = false
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    let onSelect: () -> Void

    private var messageCount: Int {
        conversation.messages?.count ?? 0
    }

    private var lastMessageText: String {
        guard let messages = conversation.messages?.allObjects as? [Message],
              let lastMessage = messages.sorted(by: {
                  ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast)
              }).last else {
            return "No messages"
        }
        return lastMessage.content?.prefix(100).description ?? "No content"
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.title ?? "Untitled Chat")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    if let date = conversation.updatedAt {
                        Text(date, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(lastMessageText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack {
                    Text("\(messageCount) messages")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ChatHistoryView(isPresented: .constant(true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}