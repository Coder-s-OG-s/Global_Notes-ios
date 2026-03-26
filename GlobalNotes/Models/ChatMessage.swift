import Foundation

/// A single message in an AI chat conversation.
struct ChatMessage: Identifiable {
    let id: UUID
    let role: String   // "user" or "assistant"
    let content: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        role: String,
        content: String,
        timestamp: Date = .now
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}
