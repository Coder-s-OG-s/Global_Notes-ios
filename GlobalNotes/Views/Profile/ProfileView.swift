import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showSignOutConfirm = false
    @State private var totalNotes = 0
    @State private var totalWords = 0

    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.15))
                                .frame(width: 64, height: 64)

                            Text(profileVM.profile?.initials ?? "?")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.accentColor)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(profileVM.profile?.displayName ?? "User")
                                .font(.headline)

                            if let email = authViewModel.currentUser?.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let joined = profileVM.profile?.joined {
                                Text("Joined \(joined)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Stats
                Section("Notes") {
                    HStack {
                        Label("Total Notes", systemImage: "doc.text")
                        Spacer()
                        Text("\(totalNotes)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Total Words", systemImage: "textformat.abc")
                        Spacer()
                        Text("\(totalWords)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Sync Status", systemImage: "arrow.triangle.2.circlepath")
                        Spacer()
                        Text(SupabaseManager.shared.isConfigured ? "Connected" : "Offline")
                            .font(.caption)
                            .foregroundStyle(SupabaseManager.shared.isConfigured ? .green : .orange)
                    }
                }

                // App Info
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                // Sign Out
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            Spacer()
                        }
                    }
                }
            }
            .alert("Sign Out", isPresented: $showSignOutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if profileVM.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .task {
                await profileVM.loadProfile()
                // Calculate stats
                let descriptor = FetchDescriptor<NoteItem>()
                if let notes = try? modelContext.fetch(descriptor) {
                    totalNotes = notes.count
                    totalWords = notes.reduce(0) { sum, note in
                        sum + note.content.strippingHTML.split(whereSeparator: { $0.isWhitespace }).count
                    }
                }
            }
        }
    }
}
