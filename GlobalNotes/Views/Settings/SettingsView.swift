import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0 // 0=system, 1=light, 2=dark
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $preferredColorScheme) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                }

                Section("Editor") {
                    Toggle("Auto-save", isOn: $autoSaveEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }

                Section("Data") {
                    HStack {
                        Label("Cloud Sync", systemImage: "icloud")
                        Spacer()
                        Text(SupabaseManager.shared.isConfigured ? "Active" : "Offline")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                SupabaseManager.shared.isConfigured
                                    ? Color.green.opacity(0.15)
                                    : Color.orange.opacity(0.15),
                                in: Capsule()
                            )
                            .foregroundStyle(SupabaseManager.shared.isConfigured ? .green : .orange)
                    }
                }

                Section("About") {
                    Link(destination: URL(string: "https://github.com/Coder-s-OG-s/Global_Notes-ios")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
