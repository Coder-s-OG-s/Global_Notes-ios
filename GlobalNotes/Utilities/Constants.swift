import Foundation

enum AppConstants {
    // MARK: - Supabase
    // These values should match your web app's config.js
    // For production, load from a gitignored Config.plist or environment
    static let supabaseURL = Config.supabaseURL
    static let supabaseAnonKey = Config.supabaseAnonKey

    // MARK: - Gemini AI
    static let geminiAPIKey = Config.geminiAPIKey
    static let geminiModel = "gemma-3-4b-it"
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"

    // MARK: - OAuth
    static let redirectURL = "globalnotesapp://auth/callback"
    static let googleProvider = "google"
    static let githubProvider = "github"

    // MARK: - Defaults
    static let defaultNoteTitle = "Untitled Note"
    static let autoSaveDelay: TimeInterval = 2.0
    static let searchDebounceDelay: TimeInterval = 0.3
}

/// Loads config from Config.plist (gitignored) with fallback to empty strings
private enum Config {
    nonisolated(unsafe) private static let config: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            print("⚠️ Config.plist not found — running in offline mode")
            return [:]
        }
        return dict
    }()

    static var supabaseURL: String {
        config["SUPABASE_URL"] as? String ?? ""
    }

    static var supabaseAnonKey: String {
        config["SUPABASE_ANON_KEY"] as? String ?? ""
    }

    static var geminiAPIKey: String {
        config["GEMINI_API_KEY"] as? String ?? ""
    }
}
