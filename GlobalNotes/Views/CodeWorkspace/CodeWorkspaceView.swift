import SwiftUI
import SwiftData

/// Main code workspace view with snippet management and AI chat.
struct CodeWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CodeWorkspaceViewModel()
    @State private var showAIAssistant = false

    private let languages = LanguageMap.languages

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // Snippet list sidebar
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Snippets")
                            .font(.headline)
                        Spacer()
                        Button {
                            viewModel.createSnippet(context: modelContext)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    Divider()

                    List(viewModel.snippets, id: \.id, selection: Binding(
                        get: { viewModel.selectedSnippet?.id },
                        set: { newID in
                            viewModel.selectedSnippet = viewModel.snippets.first { $0.id == newID }
                        }
                    )) { snippet in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(snippet.title)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text(snippet.language)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteSnippet(snippet, context: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .frame(width: 200)

                Divider()

                // Detail
                if let snippet = viewModel.selectedSnippet {
                    VStack(spacing: 0) {
                        // Title + language
                        HStack {
                            TextField("Title", text: Binding(
                                get: { snippet.title },
                                set: {
                                    snippet.title = $0
                                    viewModel.updateSnippet(snippet, context: modelContext)
                                }
                            ))
                            .textFieldStyle(.plain)
                            .font(.headline)

                            Picker("Language", selection: Binding(
                                get: { snippet.language },
                                set: {
                                    snippet.language = $0
                                    viewModel.updateSnippet(snippet, context: modelContext)
                                }
                            )) {
                                ForEach(languages, id: \.self) { lang in
                                    Text(lang).tag(lang)
                                }
                            }
                            .frame(width: 140)
                        }
                        .padding()

                        Divider()

                        // Code editor
                        TextEditor(text: Binding(
                            get: { snippet.code },
                            set: {
                                snippet.code = $0
                                viewModel.updateSnippet(snippet, context: modelContext)
                            }
                        ))
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(.systemGray6))

                        Divider()

                        // AI chat section
                        VStack(spacing: 8) {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(viewModel.chatMessages) { msg in
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
                                .padding(.horizontal)
                            }
                            .frame(height: 160)

                            HStack {
                                TextField("Ask about your code...", text: $viewModel.userInput)
                                    .textFieldStyle(.roundedBorder)

                                Button {
                                    viewModel.sendMessage()
                                } label: {
                                    Image(systemName: viewModel.isGenerating ? "hourglass" : "paperplane.fill")
                                }
                                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isGenerating)

                                Button {
                                    showAIAssistant = true
                                } label: {
                                    Image(systemName: "sparkles")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Snippet Selected",
                        systemImage: "curlybraces",
                        description: Text("Select or create a snippet to start coding.")
                    )
                }
            }
            .navigationTitle("Code Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.fetchSnippets(context: modelContext) }
            .sheet(isPresented: $showAIAssistant) {
                if let snippet = viewModel.selectedSnippet {
                    CodeAIAssistantView(
                        code: snippet.code,
                        language: snippet.language,
                        chatMessages: $viewModel.chatMessages,
                        isGenerating: $viewModel.isGenerating
                    )
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
