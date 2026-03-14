import SwiftUI
import SwiftData

struct NoteEditorView: View {
    let note: NoteItem
    @ObservedObject var viewModel: NotesListViewModel
    @StateObject private var editorVM = NoteEditorViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showAIAssistant = false
    @State private var showExportSheet = false
    @State private var showTagInput = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar metadata
            editorToolbar

            Divider()

            // Title
            TextField("Note title", text: $editorVM.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .onChange(of: editorVM.title) {
                    editorVM.titleChanged(context: modelContext)
                }

            // Tags
            if !editorVM.tags.isEmpty || showTagInput {
                TagInputView(
                    tags: $editorVM.tags,
                    showInput: $showTagInput,
                    onAdd: { tag in editorVM.addTag(tag, context: modelContext) },
                    onRemove: { tag in editorVM.removeTag(tag, context: modelContext) }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            // Formatting toolbar
            FormattingToolbar()
                .padding(.horizontal, 8)

            Divider()

            // Rich Text Editor
            RichTextEditor(
                htmlContent: $editorVM.htmlContent,
                onContentChange: {
                    editorVM.contentChanged(context: modelContext)
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    // Favorite
                    Button {
                        Task { @MainActor in await viewModel.toggleFavorite(note, context: modelContext) }
                        editorVM.isFavorite.toggle()
                    } label: {
                        Image(systemName: editorVM.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(editorVM.isFavorite ? .pink : .secondary)
                    }

                    // Tag
                    Button {
                        withAnimation { showTagInput.toggle() }
                    } label: {
                        Image(systemName: "tag")
                    }

                    // More menu
                    Menu {
                        Button {
                            showAIAssistant = true
                        } label: {
                            Label("AI Assistant", systemImage: "sparkles")
                        }

                        Button {
                            showExportSheet = true
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            Task { @MainActor in await viewModel.duplicateNote(note, context: modelContext) }
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }

                        Divider()

                        Button {
                            Task { @MainActor in await viewModel.toggleArchive(note, context: modelContext) }
                        } label: {
                            Label(
                                note.isArchived ? "Unarchive" : "Archive",
                                systemImage: note.isArchived ? "tray.and.arrow.up" : "archivebox"
                            )
                        }

                        Button(role: .destructive) {
                            Task { @MainActor in await viewModel.deleteNote(note, context: modelContext) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAIAssistant) {
            AIAssistantView(editorVM: editorVM)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView(note: note)
        }
        .onAppear {
            editorVM.load(note: note)
        }
        .onChange(of: note.id) {
            editorVM.load(note: note)
        }
    }

    // MARK: - Editor Toolbar

    private var editorToolbar: some View {
        HStack(spacing: 16) {
            if editorVM.isSaving {
                HStack(spacing: 4) {
                    ProgressView()
                        .controlSize(.mini)
                    Text("Saving...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(editorVM.updatedAt?.shortDisplay ?? "")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text("\(editorVM.wordCount) words")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Text("\(editorVM.charCount) chars")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground).opacity(0.5))
    }
}

// MARK: - Export Sheet

struct ExportSheetView: View {
    let note: NoteItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button {
                    shareText(ExportService.toMarkdown(note), filename: "\(note.title).md")
                } label: {
                    Label("Markdown (.md)", systemImage: "doc.text")
                }

                Button {
                    shareText(ExportService.toPlainText(note), filename: "\(note.title).txt")
                } label: {
                    Label("Plain Text (.txt)", systemImage: "doc.plaintext")
                }

                Button {
                    if let pdfData = ExportService.toPDF(note) {
                        shareData(pdfData, filename: "\(note.title).pdf", mimeType: "application/pdf")
                    }
                } label: {
                    Label("PDF (.pdf)", systemImage: "doc.richtext")
                }
            }
            .navigationTitle("Export Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func shareText(_ text: String, filename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? text.write(to: tempURL, atomically: true, encoding: .utf8)
        share(items: [tempURL])
    }

    private func shareData(_ data: Data, filename: String, mimeType: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: tempURL)
        share(items: [tempURL])
    }

    private func share(items: [Any]) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else { return }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = rootVC.view
        rootVC.present(activityVC, animated: true)
        dismiss()
    }
}
