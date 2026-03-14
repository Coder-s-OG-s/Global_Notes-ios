import Foundation
import SwiftData
import Combine

@MainActor
final class NoteEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var htmlContent: String = ""
    @Published var tags: [String] = []
    @Published var isFavorite: Bool = false
    @Published var isArchived: Bool = false
    @Published var theme: String?
    @Published var isSaving: Bool = false
    @Published var wordCount: Int = 0
    @Published var charCount: Int = 0

    private var note: NoteItem?
    private var autoSaveTask: Task<Void, Never>?
    private let syncEngine = SyncEngine.shared

    var noteId: String? { note?.id }
    var createdAt: Date? { note?.createdAt }
    var updatedAt: Date? { note?.updatedAt }

    func load(note: NoteItem) {
        // Cancel any pending auto-save for the previous note
        autoSaveTask?.cancel()
        autoSaveTask = nil

        self.note = note
        self.title = note.title
        self.htmlContent = note.content
        self.tags = note.tags
        self.isFavorite = note.isFavorite
        self.isArchived = note.isArchived
        self.theme = note.theme
        updateCounts()
    }

    // MARK: - Auto Save

    func scheduleAutoSave(context: ModelContext) {
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try? await Task.sleep(for: .seconds(AppConstants.autoSaveDelay))
            guard !Task.isCancelled else { return }
            await save(context: context)
        }
    }

    func save(context: ModelContext) async {
        guard let note else { return }
        isSaving = true

        note.title = title.isEmpty ? AppConstants.defaultNoteTitle : title
        note.content = htmlContent
        note.tags = tags
        note.isFavorite = isFavorite
        note.isArchived = isArchived
        note.theme = theme

        await syncEngine.saveNote(note, context: context)
        isSaving = false
    }

    func cancelAutoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = nil
    }

    // MARK: - Tags

    func addTag(_ tag: String, context: ModelContext) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame })
        else { return }
        tags.append(trimmed)
        HapticManager.impact(.light)
        scheduleAutoSave(context: context)
    }

    func removeTag(_ tag: String, context: ModelContext) {
        tags.removeAll { $0 == tag }
        scheduleAutoSave(context: context)
    }

    // MARK: - Helpers

    func updateCounts() {
        let plainText = htmlContent.strippingHTML
        charCount = plainText.count
        wordCount = plainText.split(whereSeparator: { $0.isWhitespace }).count
    }

    func titleChanged(context: ModelContext) {
        scheduleAutoSave(context: context)
    }

    func contentChanged(context: ModelContext) {
        updateCounts()
        scheduleAutoSave(context: context)
    }
}
