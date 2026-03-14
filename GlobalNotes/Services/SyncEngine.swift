import Foundation
import SwiftData

/// Offline-first sync engine that mirrors web app's getNotes()/setNotes() merge logic.
/// - Saves to SwiftData immediately (offline-first)
/// - Syncs to Supabase in background when authenticated
/// - On load: fetches cloud + local, merges by ID (newer wins by updatedAt)
@MainActor
final class SyncEngine: ObservableObject {
    static let shared = SyncEngine()

    private let noteService = NoteService.shared
    private let folderService = FolderService.shared
    private let authService = AuthService.shared

    @Published var isSyncing = false
    @Published var lastSyncError: String?

    private var isSyncingNotes = false
    private var isSyncingFolders = false

    private init() {}

    // MARK: - Notes Sync

    /// Fetch and merge notes from cloud + local (mirrors web app's getNotes())
    func loadNotes(context: ModelContext) async -> [NoteItem] {
        guard !isSyncingNotes else {
            let descriptor = FetchDescriptor<NoteItem>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
            return (try? context.fetch(descriptor)) ?? []
        }

        isSyncingNotes = true
        isSyncing = true
        defer {
            isSyncingNotes = false
            isSyncing = false
        }

        var cloudNotes: [NoteDTO] = []

        // 1. Try fetching from Supabase if authenticated
        if await authService.getCurrentSession() != nil {
            do {
                cloudNotes = try await noteService.fetchNotes()
            } catch {
                lastSyncError = error.localizedDescription
                print("Cloud fetch failed: \(error.localizedDescription)")
            }
        }

        // 2. Fetch from SwiftData (local)
        let descriptor = FetchDescriptor<NoteItem>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let localNotes = (try? context.fetch(descriptor)) ?? []

        // 3. Build lookup maps
        let cloudNoteItems = cloudNotes.map { $0.toNoteItem() }
        var cloudMap: [String: NoteItem] = [:]
        for note in cloudNoteItems {
            cloudMap[note.id] = note
        }

        var localMap: [String: NoteItem] = [:]
        for note in localNotes {
            localMap[note.id] = note
        }

        // 4. Collect all unique IDs
        let allIds = Set(cloudMap.keys).union(Set(localMap.keys))

        // 5. Merge: newer wins by updatedAt, preserve local-only and cloud-only
        var mergedNotes: [NoteItem] = []
        var cloudOnlyIds: Set<String> = Set(cloudMap.keys)

        for id in allIds {
            let cloudNote = cloudMap[id]
            let localNote = localMap[id]

            if let cloud = cloudNote, let local = localNote {
                cloudOnlyIds.remove(id)
                // Both exist — newer wins
                if cloud.updatedAt > local.updatedAt {
                    // Update local with cloud data
                    local.title = cloud.title
                    local.content = cloud.content
                    local.tags = cloud.tags
                    local.folderId = cloud.folderId
                    local.theme = cloud.theme
                    local.editorPattern = cloud.editorPattern
                    local.isFavorite = cloud.isFavorite
                    local.isArchived = cloud.isArchived
                    local.updatedAt = cloud.updatedAt
                    local.isSynced = true
                    mergedNotes.append(local)
                } else {
                    // Local is newer — keep local, mark for sync
                    if local.updatedAt > cloud.updatedAt {
                        local.isSynced = false
                    }
                    mergedNotes.append(local)
                }
            } else if let local = localNote {
                // Local only — keep it, may need sync
                mergedNotes.append(local)
            } else if let cloud = cloudNote {
                cloudOnlyIds.remove(id)
                // Cloud only — insert into SwiftData
                let item = NoteItem(
                    id: cloud.id,
                    title: cloud.title,
                    content: cloud.content,
                    tags: cloud.tags,
                    folderId: cloud.folderId,
                    theme: cloud.theme,
                    editorPattern: cloud.editorPattern,
                    isFavorite: cloud.isFavorite,
                    isArchived: cloud.isArchived,
                    createdAt: cloud.createdAt,
                    updatedAt: cloud.updatedAt,
                    isSynced: true
                )
                context.insert(item)
                mergedNotes.append(item)
            }
        }

        // 6. Remove local notes that were deleted on cloud
        // (local notes whose IDs are not in cloud AND are already synced = deleted remotely)
        if !cloudNotes.isEmpty {
            for local in localNotes {
                if cloudMap[local.id] == nil && local.isSynced {
                    context.delete(local)
                    mergedNotes.removeAll { $0.id == local.id }
                }
            }
        }

        try? context.save()

        // 7. Sync unsynced local notes to cloud
        await syncPendingNotes(context: context)

        return mergedNotes.sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Save a note locally and sync to cloud
    func saveNote(_ note: NoteItem, context: ModelContext) async {
        note.updatedAt = .now
        note.isSynced = false
        try? context.save()

        // Sync to cloud in background
        if await authService.getCurrentSession() != nil {
            do {
                try await noteService.upsertNote(note)
                note.isSynced = true
                try? context.save()
            } catch {
                lastSyncError = error.localizedDescription
                print("Cloud sync failed for note \(note.id): \(error.localizedDescription)")
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
                lastSyncError = error.localizedDescription
                print("Cloud delete failed for note \(noteId): \(error.localizedDescription)")
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
        } catch {
            lastSyncError = error.localizedDescription
            print("Batch sync failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Folders Sync

    /// Fetch and merge folders (mirrors web app's syncFoldersFromCloud())
    func loadFolders(context: ModelContext) async -> [FolderItem] {
        guard !isSyncingFolders else {
            let descriptor = FetchDescriptor<FolderItem>()
            return (try? context.fetch(descriptor)) ?? []
        }

        isSyncingFolders = true
        defer { isSyncingFolders = false }

        var cloudFolders: [FolderDTO] = []

        if await authService.getCurrentSession() != nil {
            do {
                cloudFolders = try await folderService.fetchFolders()
            } catch {
                print("Cloud folder fetch failed: \(error.localizedDescription)")
            }
        }

        let descriptor = FetchDescriptor<FolderItem>()
        let localFolders = (try? context.fetch(descriptor)) ?? []

        let cloudFolderItems = cloudFolders.map { $0.toFolderItem() }
        var cloudMap: [String: FolderItem] = [:]
        for folder in cloudFolderItems {
            cloudMap[folder.id] = folder
        }

        var localMap: [String: FolderItem] = [:]
        for folder in localFolders {
            localMap[folder.id] = folder
        }

        let allIds = Set(cloudMap.keys).union(Set(localMap.keys))
        var mergedFolders: [FolderItem] = []

        for id in allIds {
            let cloudFolder = cloudMap[id]
            let localFolder = localMap[id]

            if let cloud = cloudFolder, let local = localFolder {
                // Both exist — cloud wins for folders (no updatedAt to compare)
                local.name = cloud.name
                local.isSynced = true
                mergedFolders.append(local)
            } else if let local = localFolder {
                mergedFolders.append(local)
            } else if let cloud = cloudFolder {
                let item = FolderItem(
                    id: cloud.id,
                    name: cloud.name,
                    createdAt: cloud.createdAt,
                    isSynced: true
                )
                context.insert(item)
                mergedFolders.append(item)
            }
        }

        // Remove locally-synced folders deleted on cloud
        if !cloudFolders.isEmpty {
            for local in localFolders {
                if cloudMap[local.id] == nil && local.isSynced {
                    context.delete(local)
                    mergedFolders.removeAll { $0.id == local.id }
                }
            }
        }

        try? context.save()

        // Sync unsynced folders
        await syncPendingFolders(context: context)

        return mergedFolders.sorted { $0.createdAt < $1.createdAt }
    }

    /// Save folder locally and sync to cloud
    func saveFolder(_ folder: FolderItem, context: ModelContext) async {
        folder.isSynced = false
        try? context.save()

        if await authService.getCurrentSession() != nil {
            do {
                try await folderService.upsertFolder(folder)
                folder.isSynced = true
                try? context.save()
            } catch {
                print("Cloud folder sync failed: \(error.localizedDescription)")
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
                print("Cloud folder delete failed: \(error.localizedDescription)")
            }
        }
    }

    /// Sync all unsynced folders to cloud
    func syncPendingFolders(context: ModelContext) async {
        guard await authService.getCurrentSession() != nil else { return }

        let descriptor = FetchDescriptor<FolderItem>(
            predicate: #Predicate<FolderItem> { !$0.isSynced }
        )
        guard let unsyncedFolders = try? context.fetch(descriptor), !unsyncedFolders.isEmpty else { return }

        for folder in unsyncedFolders {
            do {
                try await folderService.upsertFolder(folder)
                folder.isSynced = true
            } catch {
                print("Folder sync failed for \(folder.id): \(error.localizedDescription)")
            }
        }
        try? context.save()
    }
}
