import SwiftUI

struct ChatHeader: View {
    let selectedModel: String
    @Binding var isCollapsed: Bool

    var body: some View {
        HStack(spacing: 8) {
            // Logo/Title (smaller, far left)
            HStack(spacing: 4) {
                Image(systemName: "waveform.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 12, weight: .medium))

                Text("Echo")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Model indicator (center-aligned, compact)
            ModelBadge(modelName: selectedModel)

            Spacer()

            // Minimize button (far right)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isCollapsed.toggle()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: 16)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.08))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .help("Minimize chat")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.clear)
        .draggableWindow()
    }
}

struct ModelBadge: View {
    let modelName: String

    var body: some View {
        Text(modelName)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(badgeColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(badgeColor.opacity(0.08))
            )
    }

    private var badgeColor: Color {
        switch modelName.lowercased() {
        case let name where name.contains("claude") || name.contains("sonnet"):
            return .orange
        case let name where name.contains("gpt"):
            return .green
        case let name where name.contains("ollama"):
            return .purple
        default:
            return .blue
        }
    }
}

#Preview {
    ChatHeader(
        selectedModel: "Claude Sonnet",
        isCollapsed: .constant(false)
    )
    .frame(width: 300, height: 40)
}