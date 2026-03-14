import Foundation

struct UserProfile: Codable, Sendable {
    let id: String
    let username: String?
    let avatar: String?
    let description: String?
    let joined: String?

    var displayName: String {
        username ?? "User"
    }

    var initials: String {
        let name = displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
