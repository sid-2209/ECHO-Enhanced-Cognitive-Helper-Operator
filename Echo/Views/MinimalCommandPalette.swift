import SwiftUI

struct MinimalCommandPalette: View {
    let suggestions: [ChatCommand]
    let selectedIndex: Int
    let onSelect: (ChatCommand) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, command in
                Button(action: { onSelect(command) }) {
                    HStack(spacing: 8) {
                        // Icon
                        Image(systemName: command.icon)
                            .font(.system(size: 12))
                            .foregroundColor(index == selectedIndex ? .blue : .secondary)
                            .frame(width: 14, height: 14)

                        // Command
                        Text(command.command)
                            .font(.system(.caption, design: .monospaced, weight: .medium))
                            .foregroundColor(index == selectedIndex ? .blue : .primary)

                        Spacer()

                        // Description (truncated)
                        Text(command.description)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .background(
                        Rectangle()
                            .fill(index == selectedIndex ? Color.blue.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                if index < suggestions.count - 1 {
                    Divider()
                        .opacity(0.1)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

struct CompactImagePreview: View {
    @Binding var images: [NSImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    CompactImageThumbnail(
                        image: image,
                        onRemove: {
                            images.remove(at: index)
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(
            Rectangle()
                .fill(Color.secondary.opacity(0.03))
        )
    }
}

struct CompactImageThumbnail: View {
    let image: NSImage
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Image
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipped()
                .cornerRadius(6)

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.6))
                            .frame(width: 12, height: 12)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: 4, y: -4)
        }
    }
}

#Preview {
    VStack {
        MinimalCommandPalette(
            suggestions: Array(ChatCommand.allCommands.prefix(4)),
            selectedIndex: 1,
            onSelect: { command in
                print("Selected: \(command.command)")
            }
        )
        .frame(width: 280)
    }
    .padding()
}