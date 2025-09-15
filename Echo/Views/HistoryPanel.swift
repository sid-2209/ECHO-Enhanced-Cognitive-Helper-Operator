import SwiftUI
import CoreData

struct HistoryPanel: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.updatedAt, ascending: false)],
        animation: .default)
    private var conversations: FetchedResults<Conversation>

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Chat History")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Conversations list
            if conversations.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)

                    Text("No chat history")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Start a conversation to see it here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(conversations, id: \.id) { conversation in
                            HistoryRow(
                                conversation: conversation,
                                onSelect: {
                                    selectConversation(conversation)
                                },
                                onDelete: {
                                    deleteConversation(conversation)
                                }
                            )

                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func selectConversation(_ conversation: Conversation) {
        // TODO: Switch to selected conversation
        NotificationCenter.default.post(
            name: NSNotification.Name("SelectConversation"),
            object: conversation
        )
        dismiss()
    }

    private func deleteConversation(_ conversation: Conversation) {
        withAnimation {
            viewContext.delete(conversation)

            do {
                try viewContext.save()
            } catch {
                print("Failed to delete conversation: \(error)")
            }
        }
    }
}

struct HistoryRow: View {
    let conversation: Conversation
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    private var lastMessage: Message? {
        if let messages = conversation.messages?.allObjects as? [Message] {
            return messages.sorted {
                ($0.timestamp ?? Date()) > ($1.timestamp ?? Date())
            }.first
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 12) {
            // Conversation icon
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                )

            // Conversation info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(conversation.title ?? "Untitled Chat")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.updatedAt ?? Date(), style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                if let lastMessage = lastMessage {
                    Text(lastMessage.content ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                // Message count
                HStack {
                    Image(systemName: "message")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text("\(conversation.messages?.count ?? 0) messages")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }

            // Delete button (shown on hover)
            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .background(
            Rectangle()
                .fill(isHovered ? Color.secondary.opacity(0.05) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    HistoryPanel()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}