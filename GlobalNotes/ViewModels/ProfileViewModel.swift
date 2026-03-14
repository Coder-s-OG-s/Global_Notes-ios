import Foundation
import Supabase

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false

    func loadProfile() async {
        guard let client = SupabaseManager.shared.client else { return }
        isLoading = true

        do {
            let user = try await client.auth.session.user
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
            print("Profile load error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
