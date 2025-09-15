# Echo - Enhanced Cognitive Helper Operator

A modern, intuitive macOS application designed to enhance your cognitive workflow through intelligent conversation and assistance.

## Features

### 🎯 Core Functionality
- **Intelligent Chat Interface**: Clean, modern chat experience with support for multiple AI models
- **Multi-Model Support**: Switch between Claude Sonnet, GPT-4, GPT-4o, and Ollama
- **Command System**: Quick access to powerful features through slash commands
- **Conversation Management**: Persistent chat history with easy navigation
- **Image Support**: Drag & drop images directly into conversations

### 🎨 User Interface
- **Compact Design**: Optimized for productivity with minimal screen footprint
- **Dark/Light Mode**: Adapts to your system preferences
- **Floating Window**: Always accessible, stays on top when needed
- **Collapsible Interface**: Minimize to focus bar when not in active use

### ⚡ Quick Commands
- `/end` - Start a new conversation
- `/clear` - Clear current conversation
- `/claude` or `/sonnet` - Switch to Claude Sonnet
- `/gpt4` - Switch to GPT-4
- `/gpt4o` - Switch to GPT-4o
- `/ollama` - Switch to Ollama
- `/screenshot` or `/ss` - Capture screenshot
- `/export` - Export conversation

### 🔧 Advanced Features
- **Global Hotkeys**: Quick access from anywhere on your Mac
- **Menu Bar Integration**: Convenient access through menu bar
- **Drag & Drop**: Support for images and files
- **Auto-scroll**: Automatically scrolls to latest messages
- **Typing Indicators**: Real-time feedback during AI responses

## Requirements

- **macOS**: 15.3 or later
- **Architecture**: Apple Silicon (arm64) or Intel (x86_64)
- **Storage**: ~50MB free space

## Installation

### Option 1: Download Release
1. Download the latest release from the [Releases page](https://github.com/yourusername/echo/releases)
2. Open the downloaded `.dmg` file
3. Drag Echo.app to your Applications folder
4. Launch Echo from Applications or Spotlight

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/yourusername/echo.git
cd echo

# Open in Xcode
open Echo.xcodeproj

# Build and run (⌘+R)
```

## Usage

### Getting Started
1. Launch Echo from Applications
2. The app will appear as a floating window
3. Start typing your message in the input field
4. Press Enter or click the send button to send

### Switching Models
Use the model selector in the header or use slash commands:
```
/claude    - Switch to Claude Sonnet
/gpt4      - Switch to GPT-4
/gpt4o     - Switch to GPT-4o
/ollama    - Switch to Ollama
```

### Managing Conversations
- **New Conversation**: Use `/end` command or click the new chat button
- **Clear Current**: Use `/clear` command
- **View History**: Access previous conversations through the history panel

### Adding Images
- **Drag & Drop**: Simply drag image files into the chat area
- **File Picker**: Click the paperclip icon to select images
- **Screenshots**: Use `/screenshot` or `/ss` to capture and attach

## Configuration

### Settings
Access settings through the gear icon in the header to configure:
- Default AI model
- Window behavior
- Hotkey preferences
- Export options

### Privacy & Security
Echo is designed with privacy in mind:
- All conversations are stored locally using Core Data
- No data is sent to external services without explicit user action
- Sandboxed app with minimal system permissions

## Development

### Project Structure
```
Echo/
├── Echo/
│   ├── Views/           # SwiftUI views and UI components
│   ├── Models/          # Data models and Core Data entities
│   ├── Utilities/       # Helper classes and utilities
│   └── Resources/       # Assets and configuration files
├── Echo.xcodeproj      # Xcode project file
└── README.md          # This file
```

### Key Technologies
- **SwiftUI**: Modern UI framework for macOS
- **Core Data**: Local data persistence
- **AppKit**: macOS-specific functionality
- **Combine**: Reactive programming patterns

### Building
1. Open `Echo.xcodeproj` in Xcode 15.0+
2. Select your target device/simulator
3. Build and run with ⌘+R

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**App won't launch**
- Ensure you're running macOS 15.3 or later
- Try right-clicking the app and selecting "Open" to bypass Gatekeeper

**Models not responding**
- Check your internet connection
- Verify API keys are configured correctly in settings
- Try switching to a different model

**Performance issues**
- Close unnecessary applications
- Restart Echo if memory usage is high
- Check macOS Activity Monitor for resource usage

### Support
- **Issues**: [GitHub Issues](https://github.com/yourusername/echo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/echo/discussions)
- **Documentation**: [Wiki](https://github.com/yourusername/echo/wiki)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with ❤️ using SwiftUI and modern macOS development practices
- Inspired by the need for seamless AI interaction in daily workflows
- Thanks to the open-source community for tools and inspiration

---

**Echo** - Enhancing human-AI collaboration, one conversation at a time.