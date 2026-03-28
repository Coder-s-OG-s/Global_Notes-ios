import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var isSigningIn = false
    @Published var isGuest = false
    @Published var currentUser: AuthService.AuthUser?
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    func checkSession() async {
        isLoading = true
        if let user = await authService.getCurrentSession() {
            currentUser = user
            isAuthenticated = true
            isGuest = false
        }
        isLoading = false
    }

    func signInWithGoogle() async {
        errorMessage = nil
        isSigningIn = true
        do {
            try await authService.signInWithGoogle()
            await checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningIn = false
    }

    func signInWithGitHub() async {
        errorMessage = nil
        isSigningIn = true
        do {
            try await authService.signInWithGitHub()
            await checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningIn = false
    }

    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        errorMessage = nil
        isSigningIn = true
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            isGuest = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningIn = false
    }

    func signUp(email: String, password: String, username: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        errorMessage = nil
        isSigningIn = true
        do {
            let user = try await authService.signUp(email: email, password: password, username: username)
            currentUser = user
            isAuthenticated = true
            isGuest = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningIn = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
            isGuest = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func continueAsGuest() {
        currentUser = nil
        isGuest = true
        isAuthenticated = true
    }

    func dismissError() {
        errorMessage = nil
    }
}
