import Foundation

struct ChatCommand: Identifiable, Equatable {
    let id = UUID()
    let command: String
    let description: String
    let icon: String

    static let allCommands: [ChatCommand] = [
        ChatCommand(command: "/end", description: "End current chat and start new", icon: "arrow.right.circle"),
        ChatCommand(command: "/clear", description: "Clear current conversation", icon: "trash"),
        ChatCommand(command: "/claude", description: "Switch to Claude and start new chat", icon: "brain.head.profile"),
        ChatCommand(command: "/sonnet", description: "Switch to Claude Sonnet and start new chat", icon: "brain.head.profile"),
        ChatCommand(command: "/gpt4", description: "Switch to GPT-4 and start new chat", icon: "cpu"),
        ChatCommand(command: "/gpt4o", description: "Switch to GPT-4o and start new chat", icon: "cpu"),
        ChatCommand(command: "/ollama", description: "Switch to local Ollama and start new chat", icon: "server.rack"),
        ChatCommand(command: "/screenshot", description: "Capture screenshot", icon: "camera"),
        ChatCommand(command: "/ss", description: "Capture screenshot (short)", icon: "camera"),
        ChatCommand(command: "/export", description: "Export current conversation", icon: "square.and.arrow.up")
    ]
}