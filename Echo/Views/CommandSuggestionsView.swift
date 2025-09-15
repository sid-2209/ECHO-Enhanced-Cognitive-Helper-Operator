import SwiftUI

struct CommandSuggestionsView: View {
    let suggestions: [ChatCommand]
    let selectedIndex: Int
    let onSelect: (ChatCommand) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, command in
                CommandSuggestionRow(
                    command: command,
                    isSelected: index == selectedIndex,
                    onSelect: { onSelect(command) }
                )
                .background(
                    Rectangle()
                        .fill(index == selectedIndex ? Color.blue.opacity(0.1) : Color.clear)
                )

                if index < suggestions.count - 1 {
                    Divider()
                        .opacity(0.3)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

struct CommandSuggestionRow: View {
    let command: ChatCommand
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: command.icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .frame(width: 16, height: 16)

                // Command and description
                VStack(alignment: .leading, spacing: 2) {
                    Text(command.command)
                        .font(.system(.callout, design: .monospaced, weight: .medium))
                        .foregroundColor(isSelected ? .blue : .primary)

                    Text(command.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Keyboard hint
                if isSelected {
                    Text("↵")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImagePreviewBar: View {
    @Binding var images: [NSImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    ImageThumbnail(
                        image: image,
                        onRemove: {
                            images.remove(at: index)
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            Rectangle()
                .fill(Color.secondary.opacity(0.05))
        )
    }
}

struct ImageThumbnail: View {
    let image: NSImage
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Image
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.5))
                            .frame(width: 16, height: 16)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: 6, y: -6)
        }
    }
}

#Preview {
    VStack {
        CommandSuggestionsView(
            suggestions: Array(ChatCommand.allCommands.prefix(5)),
            selectedIndex: 1,
            onSelect: { command in
                print("Selected: \(command.command)")
            }
        )

        ImagePreviewBar(
            images: .constant([])
        )
    }
    .frame(width: 300)
    .padding()
}