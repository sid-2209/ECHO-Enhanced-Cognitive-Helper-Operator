import SwiftUI

struct ModelSelectorPopover: View {
    @Binding var selectedModel: String
    @Environment(\.dismiss) private var dismiss

    private let models: [AIModel] = [
        AIModel(name: "Claude Sonnet", provider: "Anthropic", description: "Most capable Claude model", color: .orange),
        AIModel(name: "Claude Haiku", provider: "Anthropic", description: "Fast and lightweight", color: .orange),
        AIModel(name: "GPT-4o", provider: "OpenAI", description: "Latest GPT model with vision", color: .green),
        AIModel(name: "GPT-4", provider: "OpenAI", description: "Advanced reasoning model", color: .green),
        AIModel(name: "Ollama", provider: "Local", description: "Run models locally", color: .purple)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select Model")
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

            // Model list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(models, id: \.name) { model in
                        ModelRow(
                            model: model,
                            isSelected: selectedModel == model.name,
                            onSelect: {
                                selectedModel = model.name
                                dismiss()
                            }
                        )

                        if model.name != models.last?.name {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
            }
            .frame(height: min(CGFloat(models.count * 60), 300))
        }
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ModelRow: View {
    let model: AIModel
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Model icon
                Circle()
                    .fill(model.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: iconForProvider(model.provider))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(model.color)
                    )

                // Model info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(model.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }

                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(model.provider)
                        .font(.caption2)
                        .foregroundColor(model.color)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .background(
                Rectangle()
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func iconForProvider(_ provider: String) -> String {
        switch provider.lowercased() {
        case "anthropic":
            return "brain.head.profile"
        case "openai":
            return "cpu"
        case "local":
            return "server.rack"
        default:
            return "brain"
        }
    }
}

struct AIModel {
    let name: String
    let provider: String
    let description: String
    let color: Color
}

#Preview {
    ModelSelectorPopover(selectedModel: .constant("Claude Sonnet"))
}