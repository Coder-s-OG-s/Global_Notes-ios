import Foundation
import SwiftData

// Folder logic is handled within NotesListViewModel since folders and notes
// are tightly coupled in the UI. This file provides additional folder-specific
// utilities if needed.

extension NotesListViewModel {
    /// Notes count for a specific folder
    func noteCount(for folderId: String) -> Int {
        notes.filter { $0.folderId == folderId && !$0.isArchived }.count
    }

    /// Notes not in any folder
    var unfolderedNoteCount: Int {
        notes.filter { $0.folderId == nil && !$0.isArchived }.count
    }
}
