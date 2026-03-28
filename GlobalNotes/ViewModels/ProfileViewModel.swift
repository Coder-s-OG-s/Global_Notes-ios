import Foundation
import Supabase

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile() async {
        guard let client = SupabaseManager.shared.client else {
            errorMessage = "Not connected to cloud"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            let session = try await client.auth.session
            let user = session.user
            let response: UserProfile? = try? await client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
                .value

            profile = response ?? UserProfile(
                id: user.id.uuidString,
                username: user.userMetadata["username"]?.stringValue ?? user.email,
                avatar: nil,
                description: nil,
                joined: nil
            )
        } catch {
            errorMessage = "Failed to load profile"
        }

        isLoading = false
    }
}
