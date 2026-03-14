import Foundation
import SwiftData

// MARK: - SwiftData Model (local persistence)
@Model
final class NoteItem {
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    var tags: [String]
    var folderId: String?
    var theme: String?
    var editorPattern: String?
    var isFavorite: Bool
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var isSynced: Bool

    init(
        id: String = UUID().uuidString,
        title: String = AppConstants.defaultNoteTitle,
        content: String = "",
        tags: [String] = [],
        folderId: String? = nil,
        theme: String? = nil,
        editorPattern: String? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isSynced: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.folderId = folderId
        self.theme = theme
        self.editorPattern = editorPattern
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSynced = isSynced
    }
}

// MARK: - Supabase DTO (matches DB schema)
struct NoteDTO: Codable, Sendable {
    let id: String
    let userId: String?
    let title: String
    let content: String
    let tags: [String]?
    let folderId: String?
    let theme: String?
    let editorPattern: String?
    let isFavorite: Bool?
    let isArchived: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case tags
        case folderId = "folder_id"
        case theme
        case editorPattern = "editor_pattern"
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Convert from SwiftData model to Supabase DTO
    static func from(_ note: NoteItem, userId: String) -> NoteDTO {
        NoteDTO(
            id: note.id,
            userId: userId,
            title: note.title,
            content: note.content,
            tags: note.tags,
            folderId: note.folderId,
            theme: note.theme,
            editorPattern: note.editorPattern,
            isFavorite: note.isFavorite,
            isArchived: note.isArchived,
            createdAt: note.createdAt.iso8601String,
            updatedAt: note.updatedAt.iso8601String
        )
    }

    /// Convert Supabase DTO to SwiftData model
    func toNoteItem() -> NoteItem {
        NoteItem(
            id: id,
            title: title,
            content: content,
            tags: tags ?? [],
            folderId: folderId,
            theme: theme,
            editorPattern: editorPattern,
            isFavorite: isFavorite ?? false,
            isArchived: isArchived ?? false,
            createdAt: createdAt?.iso8601Date ?? .now,
            updatedAt: updatedAt?.iso8601Date ?? .now,
            isSynced: true
        )
    }
}

// MARK: - Insert DTO (without is_favorite/is_archived for schema compat)
struct NoteInsertDTO: Codable, Sendable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let tags: [String]?
    let folderId: String?
    let theme: String?
    let editorPattern: String?
    let isFavorite: Bool?
    let isArchived: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case tags
        case folderId = "folder_id"
        case theme
        case editorPattern = "editor_pattern"
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
