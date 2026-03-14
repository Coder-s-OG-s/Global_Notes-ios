import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0 // 0=system, 1=light, 2=dark
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("editorFontSize") private var editorFontSize = 16.0
    @AppStorage("showWordCount") private var showWordCount = true
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

                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(editorFontSize))pt")
                            .foregroundStyle(.secondary)
                        Stepper("", value: $editorFontSize, in: 12...24, step: 1)
                            .labelsHidden()
                    }

                    Toggle("Show Word Count", isOn: $showWordCount)
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }

                Section("Data") {
                    HStack {
                        Label("Cloud Sync", systemImage: "icloud")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(SupabaseManager.shared.isConfigured ? .green : .orange)
                                .frame(width: 8, height: 8)
                            Text(SupabaseManager.shared.isConfigured ? "Active" : "Offline")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

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
