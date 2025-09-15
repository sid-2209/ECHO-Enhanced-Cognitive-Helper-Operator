import SwiftUI

struct Sidebar: View {
    @Binding var isCollapsed: Bool
    @Binding var selectedSection: SidebarSection
    @Binding var selectedModel: String
    @State private var hoveredButton: SidebarButton.ButtonType?
    @State private var showModelSelector = false
    @State private var showSettings = false

    private let sidebarWidth: CGFloat = 64 // Fixed width for consistency

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Section (New Chat)
            VStack(spacing: 12) {
                SidebarButton(
                    type: .newChat,
                    icon: "plus.circle.fill",
                    isSelected: selectedSection == .chat,
                    isHovered: hoveredButton == .newChat,
                    action: {
                        if isCollapsed {
                            isCollapsed = false
                        }
                        startNewConversation()
                    }
                )
                .onHover { isHovered in
                    hoveredButton = isHovered ? .newChat : nil
                }
            }
            .padding(.top, 20) // Top section breathing room

            Spacer(minLength: 20) // Visual separation between sections

            // MARK: - Middle Section (Model & Tools)
            VStack(spacing: 16) {
                SidebarButton(
                    type: .model,
                    icon: "brain.head.profile",
                    isSelected: selectedSection == .model,
                    isHovered: hoveredButton == .model,
                    action: {
                        if isCollapsed {
                            isCollapsed = false
                        }
                        showModelSelector.toggle()
                    }
                )
                .onHover { isHovered in
                    hoveredButton = isHovered ? .model : nil
                }
                .popover(isPresented: $showModelSelector) {
                    ModelSelectorPopover(selectedModel: $selectedModel)
                }

                SidebarButton(
                    type: .toggle,
                    icon: isCollapsed ? "sidebar.left" : "sidebar.right",
                    isSelected: false,
                    isHovered: hoveredButton == .toggle,
                    action: {
                        isCollapsed.toggle()
                    }
                )
                .onHover { isHovered in
                    hoveredButton = isHovered ? .toggle : nil
                }
            }

            Spacer() // Push bottom section to bottom

            // MARK: - Bottom Section (Settings)
            VStack(spacing: 12) {
                SidebarButton(
                    type: .settings,
                    icon: "gearshape.fill",
                    isSelected: selectedSection == .settings,
                    isHovered: hoveredButton == .settings,
                    action: { showSettings.toggle() }
                )
                .onHover { isHovered in
                    hoveredButton = isHovered ? .settings : nil
                }
                .popover(isPresented: $showSettings) {
                    SettingsPopover()
                }
            }
            .padding(.bottom, 20) // Bottom section breathing room
        }
        .frame(width: sidebarWidth) // Fixed width constraint
        .frame(maxHeight: .infinity) // Fill available height
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.ultraThinMaterial.opacity(0.5)) // Subtle background for definition
        )
    }

    private func startNewConversation() {
        selectedSection = .chat
        // TODO: Clear current conversation and start new one
        NotificationCenter.default.post(name: NSNotification.Name("StartNewConversation"), object: nil)
    }
}

struct SidebarButton: View {
    enum ButtonType: Hashable {
        case newChat, model, toggle, settings

        var helpText: String {
            switch self {
            case .newChat: return "New Conversation"
            case .model: return "Select Model"
            case .toggle: return "Toggle Sidebar"
            case .settings: return "Settings"
            }
        }
    }

    let type: ButtonType
    let icon: String
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium)) // Slightly larger for better visibility
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40) // Larger touch target
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(backgroundColor)
                        .scaleEffect(isHovered ? 1.05 : 1.0) // Subtle scale on hover
                        .shadow(
                            color: shadowColor,
                            radius: shadowRadius,
                            x: 0,
                            y: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .help(type.helpText)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Visual Styling

    private var iconColor: Color {
        if isSelected {
            return .white // White on colored background
        } else if isHovered {
            return .primary
        } else {
            return .secondary.opacity(0.8)
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .accentColor // System accent color
        } else if isHovered {
            return Color(NSColor.controlAccentColor).opacity(0.15) // Subtle hover state
        } else {
            return .clear
        }
    }

    private var shadowColor: Color {
        if isSelected {
            return .black.opacity(0.15) // Subtle shadow for selected state
        } else if isHovered {
            return .black.opacity(0.08) // Light shadow on hover
        } else {
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        if isSelected {
            return 3
        } else if isHovered {
            return 2
        } else {
            return 0
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