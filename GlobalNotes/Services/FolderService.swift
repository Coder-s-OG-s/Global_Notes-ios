import Foundation
import Supabase

@MainActor
final class FolderService {
    static let shared = FolderService()

    private var client: SupabaseClient? {
        SupabaseManager.shared.client
    }

    private init() {}

    // MARK: - Fetch

    func fetchFolders() async throws -> [FolderDTO] {
        guard let client else { return [] }

        let userId = try await requireUserId()

        let response: [FolderDTO] = try await client
            .from("folders")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        return response
    }

    // MARK: - Upsert

    func upsertFolder(_ folder: FolderItem) async throws {
        guard let client else { return }

        let userId = try await requireUserId()
        let dto = FolderDTO.from(folder, userId: userId)

        try await client
            .from("folders")
            .upsert(dto)
            .execute()
    }

    // MARK: - Delete

    func deleteFolder(id: String) async throws {
        guard let client else { return }
        try await client
            .from("folders")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Helpers

    private func requireUserId() async throws -> String {
        guard let userId = await AuthService.shared.getCurrentUserId() else {
            throw ServiceError.notAuthenticated
        }
        return userId
    }
}
