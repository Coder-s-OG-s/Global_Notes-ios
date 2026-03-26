import Foundation
import SwiftData

/// A saved code snippet stored locally via SwiftData.
@Model
final class CodeSnippetItem {
    @Attribute(.unique) var id: String
    var title: String
    var code: String
    var language: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String = "Untitled",
        code: String = "",
        language: String = "Swift",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.code = code
        self.language = language
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
