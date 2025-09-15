import SwiftUI

struct SettingsPopover: View {
    @Environment(\.dismiss) private var dismiss
    @State private var opacity: Double = WindowUtilities.getWindowOpacity()
    @State private var apiKeys = APIKeys()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
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

            // Settings content
            VStack(spacing: 20) {
                // Opacity setting
                VStack(alignment: .leading, spacing: 8) {
                    Text("Window Opacity")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    HStack {
                        Text("50%")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(value: $opacity, in: 0.5...1.0, step: 0.05) {
                            Text("Opacity")
                        }
                        .onChange(of: opacity) { newValue in
                            WindowUtilities.saveWindowOpacity(newValue)
                            NotificationCenter.default.post(
                                name: NSNotification.Name("UpdateOpacity"),
                                object: newValue
                            )
                        }

                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Current: \(Int(opacity * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Divider()

                // API Keys section
                VStack(alignment: .leading, spacing: 12) {
                    Text("API Keys")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    VStack(spacing: 8) {
                        APIKeyField(
                            label: "OpenAI API Key",
                            value: $apiKeys.openAI,
                            placeholder: "sk-..."
                        )

                        APIKeyField(
                            label: "Anthropic API Key",
                            value: $apiKeys.anthropic,
                            placeholder: "sk-ant-..."
                        )
                    }
                }

                Divider()

                // General settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("General")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    VStack(spacing: 6) {
                        HStack {
                            Text("Launch at startup")
                                .font(.caption)
                                .foregroundColor(.primary)

                            Spacer()

                            Toggle("", isOn: .constant(false))
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }

                        HStack {
                            Text("Auto-hide when inactive")
                                .font(.caption)
                                .foregroundColor(.primary)

                            Spacer()

                            Toggle("", isOn: .constant(false))
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            loadAPIKeys()
        }
    }

    private func loadAPIKeys() {
        // TODO: Load from Keychain or UserDefaults
        apiKeys.openAI = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        apiKeys.anthropic = UserDefaults.standard.string(forKey: "anthropic_api_key") ?? ""
    }
}

struct APIKeyField: View {
    let label: String
    @Binding var value: String
    let placeholder: String

    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                if isSecure {
                    SecureField(placeholder, text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.caption, design: .monospaced))
                        .onChange(of: value) { newValue in
                            saveAPIKey(key: label.lowercased().replacingOccurrences(of: " ", with: "_"), value: newValue)
                        }
                } else {
                    TextField(placeholder, text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.caption, design: .monospaced))
                        .onChange(of: value) { newValue in
                            saveAPIKey(key: label.lowercased().replacingOccurrences(of: " ", with: "_"), value: newValue)
                        }
                }

                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func saveAPIKey(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

struct APIKeys {
    var openAI: String = ""
    var anthropic: String = ""
}

#Preview {
    SettingsPopover()
}