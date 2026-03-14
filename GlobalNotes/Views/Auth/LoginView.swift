import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEmailLogin = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Full-bleed dark gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.14),
                        Color(red: 0.10, green: 0.08, blue: 0.22),
                        Color(red: 0.05, green: 0.05, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle floating orbs
                Circle()
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -80, y: -geo.size.height * 0.2)

                Circle()
                    .fill(Color.purple.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: 100, y: geo.size.height * 0.15)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: geo.size.height * 0.12)

                        // Logo
                        VStack(spacing: 20) {
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.accentColor.opacity(0.2), .clear],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 70
                                        )
                                    )
                                    .frame(width: 120, height: 120)

                                // Icon circle
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 88, height: 88)
                                    .overlay {
                                        Image(systemName: "note.text")
                                            .font(.system(size: 36, weight: .medium))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    .shadow(color: Color.accentColor.opacity(0.2), radius: 20, y: 8)
                            }
                            .scaleEffect(appeared ? 1 : 0.6)
                            .opacity(appeared ? 1 : 0)

                            VStack(spacing: 8) {
                                Text("Global Notes")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("Your notes, everywhere.")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)
                        }

                        Spacer(minLength: 48)

                        // Sign in card
                        VStack(spacing: 20) {
                            if showEmailLogin {
                                emailLoginForm
                            } else {
                                // OAuth buttons
                                VStack(spacing: 12) {
                                    OAuthButton(
                                        title: "Continue with Google",
                                        iconName: "g.circle.fill",
                                        iconColor: .red,
                                        bgColor: .white,
                                        isLoading: authViewModel.isSigningIn
                                    ) {
                                        Task { await authViewModel.signInWithGoogle() }
                                    }
                                    .disabled(authViewModel.isSigningIn)

                                    OAuthButton(
                                        title: "Continue with GitHub",
                                        iconName: "chevron.left.forwardslash.chevron.right",
                                        iconColor: .white,
                                        bgColor: Color(white: 0.18),
                                        isLoading: authViewModel.isSigningIn
                                    ) {
                                        Task { await authViewModel.signInWithGitHub() }
                                    }
                                    .disabled(authViewModel.isSigningIn)
                                }

                                // Divider
                                HStack(spacing: 16) {
                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 1)
                                    Text("or")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.35))
                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 1)
                                }

                                // Email sign in
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        showEmailLogin = true
                                    }
                                } label: {
                                    Text("Sign in with Email")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background {
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                        }
                                }
                            }

                            // Guest mode
                            Button {
                                authViewModel.continueAsGuest()
                            } label: {
                                Text("Continue without account")
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .padding(.top, 4)

                            // Error
                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 28)
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.3), radius: 30, y: 15)
                        }
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)

                        Spacer(minLength: 50)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Email Form

    private var emailLoginForm: some View {
        VStack(spacing: 14) {
            if isSignUp {
                StyledTextField(placeholder: "Username", text: $username, icon: "person")
            }

            StyledTextField(placeholder: "Email", text: $email, icon: "envelope", keyboardType: .emailAddress)

            StyledSecureField(placeholder: "Password", text: $password, icon: "lock")

            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task {
                    if isSignUp {
                        await authViewModel.signUp(email: email, password: password, username: username)
                    } else {
                        await authViewModel.signIn(email: email, password: password)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if authViewModel.isSigningIn {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.small)
                    }
                    Text(authViewModel.isSigningIn ? "Signing in..." : (isSignUp ? "Create Account" : "Sign In"))
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .shadow(color: Color.accentColor.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(authViewModel.isSigningIn)

            HStack(spacing: 4) {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                    .foregroundStyle(.white.opacity(0.4))
                Button {
                    withAnimation(.spring(response: 0.3)) { isSignUp.toggle() }
                } label: {
                    Text(isSignUp ? "Sign In" : "Sign Up")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .font(.caption)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    showEmailLogin = false
                }
            } label: {
                Label("Back to sign in options", systemImage: "arrow.left")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Styled Text Fields

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                .font(.subheadline)
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

struct StyledSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)

            SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

// MARK: - OAuth Button

struct OAuthButton: View {
    let title: String
    let iconName: String
    let iconColor: Color
    let bgColor: Color
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(bgColor == .white ? .black : .white)

                Spacer()

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(bgColor == .white ? .black : .white)
                } else {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(bgColor == .white ? .black.opacity(0.3) : .white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(bgColor.opacity(isLoading ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
