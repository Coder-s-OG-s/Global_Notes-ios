import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEmailLogin = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.accentColor.opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)

                    // Logo & Title
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 100, height: 100)

                            Image(systemName: "note.text")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(Color.accentColor)
                        }

                        Text("Global Notes")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Your notes, everywhere.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // OAuth Buttons
                    VStack(spacing: 14) {
                        OAuthButton(
                            title: "Continue with Google",
                            icon: "g.circle.fill",
                            color: Color(.systemRed)
                        ) {
                            Task { await authViewModel.signInWithGoogle() }
                        }

                        OAuthButton(
                            title: "Continue with GitHub",
                            icon: "chevron.left.forwardslash.chevron.right",
                            color: Color(.label)
                        ) {
                            Task { await authViewModel.signInWithGitHub() }
                        }
                    }
                    .padding(.horizontal, 32)

                    // Divider
                    HStack {
                        Rectangle().fill(Color(.separator)).frame(height: 1)
                        Text("or").font(.caption).foregroundStyle(.secondary)
                        Rectangle().fill(Color(.separator)).frame(height: 1)
                    }
                    .padding(.horizontal, 40)

                    // Email/Password
                    if showEmailLogin {
                        emailLoginForm
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showEmailLogin = true
                            }
                        } label: {
                            Text("Sign in with Email")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.accentColor)
                        }
                    }

                    // Guest Mode
                    Button {
                        authViewModel.continueAsGuest()
                    } label: {
                        Text("Continue without account")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Error
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }

    private var emailLoginForm: some View {
        VStack(spacing: 14) {
            if isSignUp {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    if isSignUp {
                        await authViewModel.signUp(email: email, password: password, username: username)
                    } else {
                        await authViewModel.signIn(email: email, password: password)
                    }
                }
            } label: {
                Text(isSignUp ? "Create Account" : "Sign In")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            }

            Button {
                withAnimation { isSignUp.toggle() }
            } label: {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 32)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - OAuth Button

struct OAuthButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
