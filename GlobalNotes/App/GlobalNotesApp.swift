import SwiftUI
import SwiftData

@main
struct GlobalNotesApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            NoteItem.self,
            FolderItem.self
        ])

        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Attempt recovery by deleting corrupted store
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)

            do {
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                // Last resort: in-memory only so the app doesn't crash
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                modelContainer = try! ModelContainer(for: schema, configurations: [memoryConfig])
            }
        }

        SupabaseManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .modelContainer(modelContainer)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        let context = modelContainer.mainContext
                        try? context.save()
                    }
                }
        }
    }
}
