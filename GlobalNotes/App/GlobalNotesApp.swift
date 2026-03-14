import SwiftUI
import SwiftData

@main
struct GlobalNotesApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                NoteItem.self,
                FolderItem.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }

        SupabaseManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .modelContainer(modelContainer)
        }
    }
}
