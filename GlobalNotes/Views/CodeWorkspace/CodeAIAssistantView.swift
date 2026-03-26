import SwiftUI

/// Sheet view providing AI coding assistance with preset actions.
struct CodeAIAssistantView: View {
    let code: String
    let language: String
    @Binding var chatMessages: [ChatMessage]
    @Binding var isGenerating: Bool

    @State private var userInput = ""
    @Environment(\.dismiss) private var dismiss

    private let presets: [(label: String, icon: String, promptPrefix: String)] = [
        ("Explain", "questionmark.circle", "Explain the following code in detail:"),
        ("Add Docs", "doc.text", "Add documentation comments to the following code:"),
        ("Improve", "arrow.up.circle", "Suggest improvements for the following code:"),
        ("Debug", "ladybug", "Find potential bugs in the following code:")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatMessages) { msg in
                            HStack {
                                if msg.role == "user" { Spacer() }
                                Text(msg.content)
                                    .padding(10)
                                    .background(msg.role == "user" ? Color.accentColor.opacity(0.2) : Color(.systemGray5))
                                    .cornerRadius(10)
                                    .textSelection(.enabled)
                                if msg.role == "assistant" { Spacer() }
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // Preset action buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(presets, id: \.label) { preset in
                            Button {
                                sendPreset(preset.promptPrefix)
                            } label: {
                                Label(preset.label, systemImage: preset.icon)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .disabled(isGenerating)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider()

                // Text input
                HStack {
                    TextField("Ask anything...", text: $userInput)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        sendCustom()
                    } label: {
                        Image(systemName: isGenerating ? "hourglass" : "paperplane.fill")
                    }
                    .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isGenerating)
                }
                .padding()
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sendPreset(_ prefix: String) {
        let prompt = """
        \(prefix)

        Language: \(language)
        ```
        \(code)
        ```
        """
        sendPrompt(userText: prefix, fullPrompt: prompt)
    }

    private func sendCustom() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        userInput = ""

        let prompt = """
        The user is working on \(language) code:
        ```
        \(code)
        ```

        User: \(text)
        """
        sendPrompt(userText: text, fullPrompt: prompt)
    }

    private func sendPrompt(userText: String, fullPrompt: String) {
        chatMessages.append(ChatMessage(role: "user", content: userText))
        isGenerating = true

        Task {
            do {
                let response = try await GeminiService.shared.generateText(prompt: fullPrompt)
                chatMessages.append(ChatMessage(role: "assistant", content: response))
            } catch {
                chatMessages.append(ChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)"))
            }
            isGenerating = false
        }
    }
}
