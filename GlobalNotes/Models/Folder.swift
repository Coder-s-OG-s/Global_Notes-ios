import Foundation
import SwiftData

// MARK: - SwiftData Model
@Model
final class FolderItem {
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date
    var isSynced: Bool

    init(
        id: String = UUID().uuidString,
        name: String = "New Folder",
        createdAt: Date = .now,
        isSynced: Bool = false
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.isSynced = isSynced
    }
}

// MARK: - Supabase DTO
struct FolderDTO: Codable, Sendable {
    let id: String
    let userId: String?
    let name: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case createdAt = "created_at"
    }

    static func from(_ folder: FolderItem, userId: String) -> FolderDTO {
        FolderDTO(
            id: folder.id,
            userId: userId,
            name: folder.name,
            createdAt: folder.createdAt.iso8601String
        )
    }

    func toFolderItem() -> FolderItem {
        FolderItem(
            id: id,
            name: name,
            createdAt: createdAt?.iso8601Date ?? .now,
            isSynced: true
        )
    }
}
