import Foundation
import SwiftData

/// Offline-first sync engine that mirrors web app's getNotes()/setNotes() merge logic.
/// - Saves to SwiftData immediately (offline-first)
/// - Syncs to Supabase in background when authenticated
/// - On load: fetches cloud + local, merges by ID (cloud wins for same ID)
@MainActor
final class SyncEngine: ObservableObject {
    private let noteService = NoteService.shared
    private let folderService = FolderService.shared
    private let authService = AuthService.shared

    // MARK: - Notes Sync

    /// Fetch and merge notes from cloud + local (mirrors web app's getNotes())
    func loadNotes(context: ModelContext) async -> [NoteItem] {
        var cloudNotes: [NoteItem] = []

        // 1. Try fetching from Supabase if authenticated
        if await authService.getCurrentSession() != nil {
            do {
                let dtos = try await noteService.fetchNotes()
                cloudNotes = dtos.map { $0.toNoteItem() }
            } catch {
                print("⚠️ Cloud fetch failed: \(error.localizedDescription)")
            }
        }

        // 2. Fetch from SwiftData (local)
        let descriptor = FetchDescriptor<NoteItem>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let localNotes = (try? context.fetch(descriptor)) ?? []

        // 3. Merge: cloud wins for same ID, local-only preserved
        var notesMap: [String: NoteItem] = [:]

        for note in cloudNotes {
            notesMap[note.id] = note
        }

        for note in localNotes {
            if notesMap[note.id] == nil {
                notesMap[note.id] = note
            }
        }

        let merged = Array(notesMap.values).sorted { $0.updatedAt > $1.updatedAt }

        // 4. Persist merged result to SwiftData
        // Clear existing and insert merged
        for note in localNotes {
            context.delete(note)
        }
        for note in merged {
            let item = NoteItem(
                id: note.id,
                title: note.title,
                content: note.content,
                tags: note.tags,
                folderId: note.folderId,
                theme: note.theme,
                editorPattern: note.editorPattern,
                isFavorite: note.isFavorite,
                isArchived: note.isArchived,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isSynced: true
            )
            context.insert(item)
        }
        try? context.save()

        return merged
    }

    /// Save a note locally and sync to cloud
    func saveNote(_ note: NoteItem, context: ModelContext) async {
        note.updatedAt = .now
        try? context.save()

        // Sync to cloud in background
        if await authService.getCurrentSession() != nil {
            do {
                try await noteService.upsertNote(note)
                note.isSynced = true
                try? context.save()
            } catch {
                note.isSynced = false
                print("⚠️ Cloud sync failed for note \(note.id): \(error.localizedDescription)")
            }
        }
    }

    /// Delete a note locally and from cloud
    func deleteNote(_ note: NoteItem, context: ModelContext) async {
        let noteId = note.id
        context.delete(note)
        try? context.save()

        // Delete from cloud
        if await authService.getCurrentSession() != nil {
            do {
                try await noteService.deleteNote(id: noteId)
            } catch {
                print("⚠️ Cloud delete failed for note \(noteId): \(error.localizedDescription)")
            }
        }
    }

    /// Sync all unsynced notes to cloud
    func syncPendingNotes(context: ModelContext) async {
        guard await authService.getCurrentSession() != nil else { return }

        let descriptor = FetchDescriptor<NoteItem>(
            predicate: #Predicate<NoteItem> { !$0.isSynced }
        )
        guard let unsyncedNotes = try? context.fetch(descriptor), !unsyncedNotes.isEmpty else { return }

        do {
            try await noteService.upsertNotes(unsyncedNotes)
            for note in unsyncedNotes {
                note.isSynced = true
            }
            try? context.save()
            print("✅ Synced \(unsyncedNotes.count) pending notes")
        } catch {
            print("⚠️ Batch sync failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Folders Sync

    /// Fetch and merge folders (mirrors web app's syncFoldersFromCloud())
    func loadFolders(context: ModelContext) async -> [FolderItem] {
        var cloudFolders: [FolderItem] = []

        if await authService.getCurrentSession() != nil {
            do {
                let dtos = try await folderService.fetchFolders()
                cloudFolders = dtos.map { $0.toFolderItem() }
            } catch {
                print("⚠️ Cloud folder fetch failed: \(error.localizedDescription)")
            }
        }

        let descriptor = FetchDescriptor<FolderItem>()
        let localFolders = (try? context.fetch(descriptor)) ?? []

        // Merge: cloud wins for same ID
        var foldersMap: [String: FolderItem] = [:]
        for folder in cloudFolders {
            foldersMap[folder.id] = folder
        }
        for folder in localFolders {
            if foldersMap[folder.id] == nil {
                foldersMap[folder.id] = folder
            }
        }

        let merged = Array(foldersMap.values).sorted { $0.createdAt < $1.createdAt }

        // Persist
        for folder in localFolders {
            context.delete(folder)
        }
        for folder in merged {
            let item = FolderItem(
                id: folder.id,
                name: folder.name,
                createdAt: folder.createdAt,
                isSynced: true
            )
            context.insert(item)
        }
        try? context.save()

        return merged
    }

    /// Save folder locally and sync to cloud
    func saveFolder(_ folder: FolderItem, context: ModelContext) async {
        try? context.save()

        if await authService.getCurrentSession() != nil {
            do {
                try await folderService.upsertFolder(folder)
                folder.isSynced = true
                try? context.save()
            } catch {
                print("⚠️ Cloud folder sync failed: \(error.localizedDescription)")
            }
        }
    }

    /// Delete folder locally and from cloud
    func deleteFolder(_ folder: FolderItem, context: ModelContext) async {
        let folderId = folder.id
        context.delete(folder)
        try? context.save()

        if await authService.getCurrentSession() != nil {
            do {
                try await folderService.deleteFolder(id: folderId)
            } catch {
                print("⚠️ Cloud folder delete failed: \(error.localizedDescription)")
            }
        }
    }
}
