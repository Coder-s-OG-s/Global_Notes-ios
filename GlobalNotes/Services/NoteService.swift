import Foundation
import Supabase

@MainActor
final class NoteService {
    static let shared = NoteService()

    private var client: SupabaseClient? {
        SupabaseManager.shared.client
    }

    /// Whether the Supabase schema has is_favorite/is_archived columns
    /// Mirrors web app's _hasExtendedColumns pattern
    private var hasExtendedColumns: Bool? = nil

    private init() {}

    // MARK: - Fetch

    func fetchNotes() async throws -> [NoteDTO] {
        guard let client else { return [] }

        let userId = try await requireUserId()

        let response: [NoteDTO] = try await client
            .from("notes")
            .select()
            .eq("user_id", value: userId)
            .order("updated_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Upsert

    func upsertNotes(_ notes: [NoteItem]) async throws {
        guard let client else { return }

        let userId = try await requireUserId()

        let dtos = notes.map { note in
            NoteInsertDTO(
                id: note.id,
                userId: userId,
                title: note.title,
                content: note.content,
                tags: note.tags,
                folderId: note.folderId,
                theme: note.theme,
                editorPattern: note.editorPattern,
                isFavorite: hasExtendedColumns != false ? note.isFavorite : nil,
                isArchived: hasExtendedColumns != false ? note.isArchived : nil,
                createdAt: note.createdAt.iso8601String,
                updatedAt: note.updatedAt.iso8601String
            )
        }

        do {
            try await client.from("notes").upsert(dtos).execute()

            if hasExtendedColumns == nil {
                hasExtendedColumns = true
            }
        } catch {
            // Only retry without extended columns if we haven't determined schema yet
            // and the error looks like a schema mismatch (not a network/auth error)
            let errorString = "\(error)"
            let isSchemaError = errorString.contains("column") || errorString.contains("undefined") || errorString.contains("400") || errorString.contains("42703")

            if hasExtendedColumns == nil && isSchemaError {
                let fallbackDtos = notes.map { note in
                    NoteInsertDTO(
                        id: note.id,
                        userId: userId,
                        title: note.title,
                        content: note.content,
                        tags: note.tags,
                        folderId: note.folderId,
                        theme: note.theme,
                        editorPattern: note.editorPattern,
                        isFavorite: nil,
                        isArchived: nil,
                        createdAt: note.createdAt.iso8601String,
                        updatedAt: note.updatedAt.iso8601String
                    )
                }
                do {
                    try await client.from("notes").upsert(fallbackDtos).execute()
                    hasExtendedColumns = false
                } catch {
                    throw error
                }
            } else {
                throw error
            }
        }
    }

    func upsertNote(_ note: NoteItem) async throws {
        try await upsertNotes([note])
    }

    // MARK: - Delete

    func deleteNote(id: String) async throws {
        guard let client else { return }
        try await client
            .from("notes")
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

enum ServiceError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please sign in."
        }
    }
}
