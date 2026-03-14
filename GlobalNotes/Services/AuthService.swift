import Foundation
import Supabase
import AuthenticationServices

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    private var client: SupabaseClient? {
        SupabaseManager.shared.client
    }

    struct AuthUser: Sendable {
        let id: String
        let email: String?
        let username: String?
    }

    // MARK: - Session

    func getCurrentSession() async -> AuthUser? {
        guard let client else { return nil }
        do {
            let session = try await client.auth.session
            let user = session.user
            return AuthUser(
                id: user.id.uuidString,
                email: user.email,
                username: user.userMetadata["username"]?.stringValue ?? user.email
            )
        } catch {
            return nil
        }
    }

    func getCurrentUserId() async -> String? {
        let user = await getCurrentSession()
        return user?.id
    }

    // MARK: - OAuth Sign In

    func signInWithGoogle() async throws {
        guard let client else {
            throw AuthError.notConfigured
        }
        try await client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: AppConstants.redirectURL)
        )
    }

    func signInWithGitHub() async throws {
        guard let client else {
            throw AuthError.notConfigured
        }
        try await client.auth.signInWithOAuth(
            provider: .github,
            redirectTo: URL(string: AppConstants.redirectURL)
        )
    }

    // MARK: - Email/Password (if needed)

    func signIn(email: String, password: String) async throws -> AuthUser {
        guard let client else {
            throw AuthError.notConfigured
        }
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        return AuthUser(
            id: session.user.id.uuidString,
            email: session.user.email,
            username: session.user.userMetadata["username"]?.stringValue ?? session.user.email
        )
    }

    func signUp(email: String, password: String, username: String) async throws -> AuthUser {
        guard let client else {
            throw AuthError.notConfigured
        }
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )
        let user = response.user
        return AuthUser(
            id: user.id.uuidString,
            email: user.email,
            username: username
        )
    }

    // MARK: - Sign Out

    func signOut() async throws {
        guard let client else { return }
        try await client.auth.signOut()
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case notConfigured
        case signUpFailed

        var errorDescription: String? {
            switch self {
            case .notConfigured:
                return "Supabase is not configured. Please add your credentials to Config.plist."
            case .signUpFailed:
                return "Sign up failed. Please try again."
            }
        }
    }
}

// MARK: - JSON value helper
extension AnyJSON {
    var stringValue: String? {
        switch self {
        case .string(let s): return s
        default: return nil
        }
    }
}
