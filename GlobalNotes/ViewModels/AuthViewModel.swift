import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: AuthService.AuthUser?
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    func checkSession() async {
        isLoading = true
        if let user = await authService.getCurrentSession() {
            currentUser = user
            isAuthenticated = true
        }
        isLoading = false
    }

    func signInWithGoogle() async {
        errorMessage = nil
        do {
            try await authService.signInWithGoogle()
            await checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGitHub() async {
        errorMessage = nil
        do {
            try await authService.signInWithGitHub()
            await checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, username: String) async {
        errorMessage = nil
        do {
            let user = try await authService.signUp(email: email, password: password, username: username)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func continueAsGuest() {
        currentUser = nil
        isAuthenticated = true  // Allow app access without cloud sync
    }
}
