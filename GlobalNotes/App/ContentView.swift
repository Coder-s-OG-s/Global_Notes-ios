import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0

    private var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        Group {
            if authViewModel.isLoading {
                LaunchScreenView()
            } else if authViewModel.isAuthenticated {
                MainAppView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isLoading)
        .preferredColorScheme(colorScheme)
        .task {
            await authViewModel.checkSession()
        }
    }
}

struct LaunchScreenView: View {
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.8

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "note.text")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(Color.accentColor)

                Text("Global Notes")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1
                scale = 1
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
