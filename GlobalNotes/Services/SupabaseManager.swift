import Foundation
import Supabase

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    private(set) var client: SupabaseClient?
    private(set) var isConfigured = false

    private init() {}

    func initialize() {
        let url = AppConstants.supabaseURL
        let key = AppConstants.supabaseAnonKey

        guard !url.isEmpty, !key.isEmpty,
              let supabaseURL = URL(string: url) else {
            print("⚠️ Supabase not configured — running in offline mode")
            return
        }

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: key
        )
        isConfigured = true
        print("✅ Supabase client initialized")
    }
}
