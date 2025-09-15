import SwiftUI

struct Sidebar: View {
    @Binding var isCollapsed: Bool
    @Binding var selectedSection: SidebarSection
    @Binding var selectedModel: String
    @State private var hoveredSection: SidebarSection?
    @State private var showModelSelector = false
    @State private var showHistoryPanel = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 16) {
            // New Conversation Button
            Button(action: {
                if isCollapsed {
                    isCollapsed = false
                }
                startNewConversation()
            }) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                    .foregroundColor(selectedSection == .chat ? .blue : .secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .help("New Conversation")

            // Model Selector Button
            Button(action: {
                if isCollapsed {
                    isCollapsed = false
                }
                showModelSelector.toggle()
            }) {
                Image(systemName: "cpu")
                    .font(.system(size: 16))
                    .foregroundColor(selectedSection == .model ? .blue : .secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .help("Select Model")
            .popover(isPresented: $showModelSelector) {
                ModelSelectorPopover(selectedModel: $selectedModel)
            }

            // History Button
            Button(action: {
                if isCollapsed {
                    isCollapsed = false
                }
                showHistoryPanel.toggle()
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(selectedSection == .history ? .blue : .secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .help("Chat History")

            Spacer()

            // Expand/Collapse Button
            Button(action: {
                isCollapsed.toggle()
            }) {
                Image(systemName: isCollapsed ? "chevron.left" : "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .help(isCollapsed ? "Expand Chat" : "Collapse Chat")

            // Settings Button (at bottom)
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .foregroundColor(selectedSection == .settings ? .blue : .secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .help("Settings")
            .popover(isPresented: $showSettings) {
                SettingsPopover()
            }
        }
        .padding(.vertical, 16)
        .frame(maxHeight: .infinity)
        .background(Color.clear)
        .sheet(isPresented: $showHistoryPanel) {
            ChatHistoryView(isPresented: $showHistoryPanel)
        }
    }

    private func startNewConversation() {
        selectedSection = .chat
        // TODO: Clear current conversation and start new one
        NotificationCenter.default.post(name: NSNotification.Name("StartNewConversation"), object: nil)
    }
}

struct SidebarButton: View {
    let section: SidebarSection
    let isSelected: Bool
    let isHovered: Bool
    let isCollapsed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: section.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .scaleEffect(isHovered || isSelected ? 1.05 : 1.0)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .help(section.title)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var iconColor: Color {
        if isSelected {
            return .blue
        } else if isHovered {
            return .primary
        } else {
            return .secondary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.1)
        } else if isHovered {
            return .secondary.opacity(0.1)
        } else {
            return .clear
        }
    }
}

#Preview {
    Sidebar(
        isCollapsed: .constant(false),
        selectedSection: .constant(.chat),
        selectedModel: .constant("Claude Sonnet")
    )
    .frame(width: 50, height: 500)
}