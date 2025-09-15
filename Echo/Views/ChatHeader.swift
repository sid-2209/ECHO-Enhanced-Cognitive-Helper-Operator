import SwiftUI

struct ChatHeader: View {
    let selectedModel: String
    @Binding var isCollapsed: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // App icon for branding
                Image(systemName: "waveform.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))

                // Main title with model - "Echo using [Model Name]" format
                HStack(spacing: 0) {
                    Text("Echo")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.primary)

                    Text(" using ")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.secondary)

                    Text(selectedModel)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(modelColor)
                }

                Spacer()

                // Minimize button (far right)
                Button(action: {
                    isCollapsed.toggle()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.8))
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.06))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Minimize chat")
            }
            .padding(.horizontal, 16)  // Increased padding for better spacing
            .padding(.vertical, 12)    // Increased vertical padding for prominence

            // Subtle separator line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primary.opacity(0.1),
                            Color.primary.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .background(
            // Subtle background with material effect
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.3))
                .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        )
        .draggableWindow()
    }

    // Dynamic model color based on the current model
    private var modelColor: Color {
        switch selectedModel.lowercased() {
        case let name where name.contains("claude") || name.contains("sonnet"):
            return .orange
        case let name where name.contains("gpt"):
            return .green
        case let name where name.contains("ollama"):
            return .purple
        default:
            return .accentColor
        }
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
    VStack(spacing: 0) {
        ChatHeader(
            selectedModel: "Claude Sonnet",
            isCollapsed: .constant(false)
        )

        // Show different model examples
        ChatHeader(
            selectedModel: "GPT-4",
            isCollapsed: .constant(false)
        )

        ChatHeader(
            selectedModel: "Ollama",
            isCollapsed: .constant(false)
        )

        Spacer()
    }
    .frame(width: 350)
}