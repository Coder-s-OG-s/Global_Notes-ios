import SwiftUI
import SwiftData

struct NotesListView: View {
    @ObservedObject var viewModel: NotesListViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showSortPicker = false
    @State private var noteToDelete: NoteItem?

    var body: some View {
        List(selection: Binding(
            get: { viewModel.selectedNoteId },
            set: { viewModel.selectedNoteId = $0 }
        )) {
            ForEach(viewModel.filteredNotes, id: \.id) { note in
                NavigationLink(value: note.id) {
                    NoteRowView(note: note)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        noteToDelete = note
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        Task { @MainActor in await viewModel.toggleArchive(note, context: modelContext) }
                    } label: {
                        Label(
                            note.isArchived ? "Unarchive" : "Archive",
                            systemImage: note.isArchived ? "tray.and.arrow.up" : "archivebox"
                        )
                    }
                    .tint(.indigo)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        Task { @MainActor in
                            await viewModel.toggleFavorite(note, context: modelContext)
                        }
                    } label: {
                        Label(
                            note.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: note.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    .tint(.pink)
                }
                .contextMenu {
                    noteContextMenu(note)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(navigationTitle)
        .searchable(text: $viewModel.searchText, prompt: "Search notes...")
        .refreshable {
            await viewModel.loadData(context: modelContext)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredNotes.isEmpty {
                emptyState
            }
        }
        .alert("Delete Note", isPresented: Binding(
            get: { noteToDelete != nil },
            set: { if !$0 { noteToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { noteToDelete = nil }
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    Task { @MainActor in await viewModel.deleteNote(note, context: modelContext) }
                }
                noteToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    // Sort
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.subheadline)
                    }

                    // New Note
                    Button {
                        Task { @MainActor in await viewModel.createNote(context: modelContext) }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                    }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
        }
    }

    // MARK: - Helpers

    private var navigationTitle: String {
        if let folderId = viewModel.selectedFolderId,
           let folder = viewModel.folders.first(where: { $0.id == folderId }) {
            return folder.name
        }
        return viewModel.libraryFilter.rawValue
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundStyle(.tertiary)

            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if viewModel.searchText.isEmpty && viewModel.libraryFilter == .all {
                Button {
                    Task { @MainActor in await viewModel.createNote(context: modelContext) }
                } label: {
                    Label("New Note", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
    }

    private var emptyStateIcon: String {
        if !viewModel.searchText.isEmpty { return "magnifyingglass" }
        switch viewModel.libraryFilter {
        case .favorites: return "heart"
        case .archived: return "archivebox"
        case .all: return "note.text"
        }
    }

    private var emptyStateMessage: String {
        if !viewModel.searchText.isEmpty { return "No notes match your search" }
        switch viewModel.libraryFilter {
        case .favorites: return "No favorite notes yet"
        case .archived: return "No archived notes"
        case .all: return "No notes yet.\nCreate your first note!"
        }
    }

    @ViewBuilder
    private func noteContextMenu(_ note: NoteItem) -> some View {
        Button {
            Task { @MainActor in await viewModel.toggleFavorite(note, context: modelContext) }
        } label: {
            Label(note.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  systemImage: note.isFavorite ? "heart.slash" : "heart")
        }

        Button {
            Task { @MainActor in await viewModel.toggleArchive(note, context: modelContext) }
        } label: {
            Label(note.isArchived ? "Unarchive" : "Archive",
                  systemImage: note.isArchived ? "tray.and.arrow.up" : "archivebox")
        }

        Button {
            Task { @MainActor in await viewModel.duplicateNote(note, context: modelContext) }
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        // Move to folder
        if !viewModel.folders.isEmpty {
            Menu("Move to Folder") {
                Button("No Folder") {
                    Task { @MainActor in await viewModel.moveToFolder(note, folderId: nil, context: modelContext) }
                }
                ForEach(viewModel.folders, id: \.id) { folder in
                    Button(folder.name) {
                        Task { @MainActor in await viewModel.moveToFolder(note, folderId: folder.id, context: modelContext) }
                    }
                }
            }
        }

        Divider()

        Button(role: .destructive) {
            noteToDelete = note
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
