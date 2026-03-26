import Foundation
import SwiftData

/// View model for the Code Workspace feature — manages snippets and AI chat.
@MainActor
final class CodeWorkspaceViewModel: ObservableObject {

    @Published var snippets: [CodeSnippetItem] = []
    @Published var selectedSnippet: CodeSnippetItem?
    @Published var chatMessages: [ChatMessage] = []
    @Published var userInput: String = ""
    @Published var isGenerating: Bool = false

    // MARK: - CRUD

    func fetchSnippets(context: ModelContext) {
        let descriptor = FetchDescriptor<CodeSnippetItem>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        snippets = (try? context.fetch(descriptor)) ?? []
    }

    func createSnippet(context: ModelContext) {
        let snippet = CodeSnippetItem()
        context.insert(snippet)
        try? context.save()
        fetchSnippets(context: context)
        selectedSnippet = snippet
    }

    func updateSnippet(_ snippet: CodeSnippetItem, context: ModelContext) {
        snippet.updatedAt = .now
        try? context.save()
        fetchSnippets(context: context)
    }

    func deleteSnippet(_ snippet: CodeSnippetItem, context: ModelContext) {
        if selectedSnippet?.id == snippet.id {
            selectedSnippet = nil
        }
        context.delete(snippet)
        try? context.save()
        fetchSnippets(context: context)
    }

    // MARK: - AI Chat

    func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMsg = ChatMessage(role: "user", content: text)
        chatMessages.append(userMsg)
        userInput = ""
        isGenerating = true

        let codeContext = selectedSnippet?.code ?? ""
        let language = selectedSnippet?.language ?? "Unknown"

        let prompt = """
        You are a coding assistant. The user is working on a \(language) code snippet.

        Code:
        ```
        \(codeContext)
        ```

        User message: \(text)

        Provide a helpful response.
        """

        Task {
            do {
                let response = try await GeminiService.shared.generateText(prompt: prompt)
                chatMessages.append(ChatMessage(role: "assistant", content: response))
            } catch {
                chatMessages.append(ChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)"))
            }
            isGenerating = false
        }
    }
}
