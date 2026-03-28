import SwiftUI

struct AIAssistantView: View {
    @ObservedObject var editorVM: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var prompt = ""
    @State private var response = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastPrompt: String?
    @State private var selectedAction: AIAction?

    enum AIAction: String, CaseIterable {
        case summarize = "Summarize"
        case expand = "Expand"
        case rewrite = "Rewrite"
        case fixGrammar = "Fix Grammar"
        case translate = "Translate"
        case custom = "Custom Prompt"

        var icon: String {
            switch self {
            case .summarize: return "text.badge.minus"
            case .expand: return "text.badge.plus"
            case .rewrite: return "arrow.triangle.2.circlepath"
            case .fixGrammar: return "text.badge.checkmark"
            case .translate: return "globe"
            case .custom: return "sparkles"
            }
        }

        func buildPrompt(content: String) -> String {
            switch self {
            case .summarize:
                return "Summarize the following text concisely:\n\n\(content)"
            case .expand:
                return "Expand and elaborate on the following text:\n\n\(content)"
            case .rewrite:
                return "Rewrite the following text to improve clarity and style:\n\n\(content)"
            case .fixGrammar:
                return "Fix all grammar and spelling errors in the following text. Only return the corrected text:\n\n\(content)"
            case .translate:
                return "Translate the following text to English (or if already in English, to Spanish):\n\n\(content)"
            case .custom:
                return content
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Quick Actions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AIAction.allCases, id: \.self) { action in
                            Button {
                                selectedAction = action
                                if action != .custom {
                                    executeAction(action)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: action.icon)
                                        .font(.caption)
                                    Text(action.rawValue)
                                        .font(.caption.weight(.medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    selectedAction == action
                                        ? Color.accentColor.opacity(0.15)
                                        : Color(.tertiarySystemFill),
                                    in: Capsule()
                                )
                                .foregroundStyle(selectedAction == action ? Color.accentColor : .primary)
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // Response area
                ScrollView {
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Thinking...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 36, weight: .ultraLight))
                                .foregroundStyle(.orange)

                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            if let retryPrompt = lastPrompt {
                                Button {
                                    generate(retryPrompt)
                                } label: {
                                    Label("Retry", systemImage: "arrow.clockwise")
                                        .font(.caption.weight(.medium))
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                        .padding(.horizontal)
                    } else if !response.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(response)
                                .font(.body)
                                .textSelection(.enabled)
                                .padding()

                            HStack {
                                Button {
                                    let htmlResponse = response.components(separatedBy: "\n")
                                        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                                        .map { "<p>\($0)</p>" }
                                        .joined()
                                    editorVM.htmlContent = htmlResponse
                                    HapticManager.notification(.success)
                                    dismiss()
                                } label: {
                                    Label("Replace Content", systemImage: "doc.on.clipboard")
                                        .font(.caption.weight(.medium))
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)

                                Button {
                                    let htmlResponse = response.components(separatedBy: "\n")
                                        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                                        .map { "<p>\($0)</p>" }
                                        .joined()
                                    editorVM.htmlContent += htmlResponse
                                    HapticManager.notification(.success)
                                    dismiss()
                                } label: {
                                    Label("Append", systemImage: "plus.doc.on.clipboard")
                                        .font(.caption.weight(.medium))
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button {
                                    UIPasteboard.general.string = response
                                    HapticManager.notification(.success)
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.caption.weight(.medium))
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundStyle(.tertiary)

                            Text("Choose an action or write a custom prompt")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }
                }

                Divider()

                // Custom prompt input
                HStack(spacing: 10) {
                    TextField("Ask AI anything...", text: $prompt, axis: .vertical)
                        .font(.subheadline)
                        .lineLimit(1...4)
                        .onSubmit { sendCustomPrompt() }

                    Button {
                        sendCustomPrompt()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(prompt.isEmpty ? Color(.tertiaryLabel) : Color.accentColor)
                    }
                    .disabled(prompt.isEmpty || isLoading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func executeAction(_ action: AIAction) {
        let noteContent = editorVM.htmlContent.strippingHTML
        let fullPrompt = action.buildPrompt(content: noteContent)
        generate(fullPrompt)
    }

    private func sendCustomPrompt() {
        let noteContent = editorVM.htmlContent.strippingHTML
        let fullPrompt = "\(prompt)\n\nContext (current note):\n\(noteContent)"
        generate(fullPrompt)
        prompt = ""
    }

    private func generate(_ prompt: String) {
        isLoading = true
        response = ""
        errorMessage = nil
        lastPrompt = prompt
        Task {
            do {
                response = try await GeminiService.shared.generateText(prompt: prompt)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
