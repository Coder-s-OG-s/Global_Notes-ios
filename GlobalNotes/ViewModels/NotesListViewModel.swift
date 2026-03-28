import Foundation
import SwiftData
import SwiftUI
import Combine

enum LibraryFilter: String, CaseIterable {
    case all = "All Notes"
    case favorites = "Favorites"
    case archived = "Archived"
}

enum SortOption: String, CaseIterable {
    case updatedNewest = "Recently Updated"
    case updatedOldest = "Oldest Updated"
    case titleAZ = "Title A-Z"
    case titleZA = "Title Z-A"
    case createdNewest = "Recently Created"
    case createdOldest = "Oldest Created"
}

@MainActor
final class NotesListViewModel: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var folders: [FolderItem] = []
    @Published var selectedNoteId: String?
    @Published var selectedFolderId: String?
    @Published var libraryFilter: LibraryFilter = .all
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .updatedNewest
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let syncEngine = SyncEngine.shared
    private var _cachedFilteredNotes: [NoteItem]?
    private var _lastFilterKey: String?

    // MARK: - Filtered & Sorted Notes

    var filteredNotes: [NoteItem] {
        let key = "\(libraryFilter.rawValue)-\(selectedFolderId ?? "")-\(searchText)-\(sortOption.rawValue)-\(notes.count)"
        if let cached = _cachedFilteredNotes, key == _lastFilterKey {
            return cached
        }
        let result = computeFilteredNotes()
        _cachedFilteredNotes = result
        _lastFilterKey = key
        return result
    }

    private func computeFilteredNotes() -> [NoteItem] {
        var result = notes

        // Library filter
        switch libraryFilter {
        case .all:
            result = result.filter { !$0.isArchived }
        case .favorites:
            result = result.filter { $0.isFavorite && !$0.isArchived }
        case .archived:
            result = result.filter { $0.isArchived }
        }

        // Folder filter
        if let folderId = selectedFolderId {
            result = result.filter { $0.folderId == folderId }
        }

        // Search
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedSearch.isEmpty {
            let query = trimmedSearch.lowercased()
            result = result.filter { note in
                note.title.lowercased().contains(query) ||
                note.content.strippingHTML.lowercased().contains(query) ||
                note.tags.contains { $0.lowercased().contains(query) }
            }
        }

        // Sort
        switch sortOption {
        case .updatedNewest:
            result.sort { $0.updatedAt > $1.updatedAt }
        case .updatedOldest:
            result.sort { $0.updatedAt < $1.updatedAt }
        case .titleAZ:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .createdNewest:
            result.sort { $0.createdAt > $1.createdAt }
        case .createdOldest:
            result.sort { $0.createdAt < $1.createdAt }
        }

        return result
    }

    var selectedNote: NoteItem? {
        notes.first { $0.id == selectedNoteId }
    }

    // MARK: - Load

    func loadData(context: ModelContext) async {
        isLoading = true
        errorMessage = nil

        notes = await syncEngine.loadNotes(context: context)
        folders = await syncEngine.loadFolders(context: context)

        if let error = syncEngine.lastSyncError {
            errorMessage = error
        }

        // Select first note if none selected
        if selectedNoteId == nil, let first = filteredNotes.first {
            selectedNoteId = first.id
        }

        isLoading = false
    }

    // MARK: - CRUD

    func createNote(context: ModelContext) async -> NoteItem {
        let note = NoteItem(
            id: UUID().uuidString.lowercased(),
            title: AppConstants.defaultNoteTitle,
            folderId: selectedFolderId
        )
        context.insert(note)
        notes.insert(note, at: 0)
        selectedNoteId = note.id

        HapticManager.impact(.medium)

        await syncEngine.saveNote(note, context: context)
        return note
    }

    func deleteNote(_ note: NoteItem, context: ModelContext) async {
        notes.removeAll { $0.id == note.id }
        if selectedNoteId == note.id {
            selectedNoteId = filteredNotes.first?.id
        }

        HapticManager.notification(.warning)

        await syncEngine.deleteNote(note, context: context)
    }

    func toggleFavorite(_ note: NoteItem, context: ModelContext) async {
        note.isFavorite.toggle()
        note.updatedAt = .now
        HapticManager.impact(.light)
        await syncEngine.saveNote(note, context: context)
    }

    func toggleArchive(_ note: NoteItem, context: ModelContext) async {
        note.isArchived.toggle()
        note.updatedAt = .now
        HapticManager.impact(.medium)
        await syncEngine.saveNote(note, context: context)

        if note.isArchived && selectedNoteId == note.id {
            selectedNoteId = filteredNotes.first?.id
        }
    }

    func moveToFolder(_ note: NoteItem, folderId: String?, context: ModelContext) async {
        note.folderId = folderId
        note.updatedAt = .now
        await syncEngine.saveNote(note, context: context)
    }

    func duplicateNote(_ note: NoteItem, context: ModelContext) async {
        let duplicate = NoteItem(
            id: UUID().uuidString.lowercased(),
            title: "\(note.title) (Copy)",
            content: note.content,
            tags: note.tags,
            folderId: note.folderId,
            theme: note.theme,
            editorPattern: note.editorPattern
        )
        context.insert(duplicate)
        notes.insert(duplicate, at: 0)
        selectedNoteId = duplicate.id

        HapticManager.impact(.light)

        await syncEngine.saveNote(duplicate, context: context)
    }

    // MARK: - Folders

    func createFolder(name: String, context: ModelContext) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let folder = FolderItem(name: trimmed)
        context.insert(folder)
        folders.append(folder)

        HapticManager.impact(.light)

        await syncEngine.saveFolder(folder, context: context)
    }

    func renameFolder(_ folder: FolderItem, newName: String, context: ModelContext) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        folder.name = trimmed
        await syncEngine.saveFolder(folder, context: context)
    }

    func deleteFolder(_ folder: FolderItem, context: ModelContext) async {
        let folderId = folder.id
        // Move notes from this folder to root and mark for sync
        for note in notes where note.folderId == folderId {
            note.folderId = nil
            note.updatedAt = .now
            note.isSynced = false
        }
        folders.removeAll { $0.id == folderId }

        if selectedFolderId == folderId {
            selectedFolderId = nil
        }

        HapticManager.notification(.warning)

        await syncEngine.deleteFolder(folder, context: context)
        await syncEngine.syncPendingNotes(context: context)
    }

    // MARK: - Selection

    func selectFolder(_ folderId: String?) {
        selectedFolderId = folderId
        libraryFilter = .all
        HapticManager.selection()
    }

    func selectLibraryFilter(_ filter: LibraryFilter) {
        libraryFilter = filter
        selectedFolderId = nil
        _cachedFilteredNotes = nil
        HapticManager.selection()
    }

    private func invalidateCache() {
        _cachedFilteredNotes = nil
    }
}
