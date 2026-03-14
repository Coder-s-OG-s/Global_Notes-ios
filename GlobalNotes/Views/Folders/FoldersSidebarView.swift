import SwiftUI
import SwiftData

struct FoldersSidebarView: View {
    @ObservedObject var viewModel: NotesListViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolderAlert = false
    @State private var newFolderName = ""

    var body: some View {
        Section {
            ForEach(viewModel.folders, id: \.id) { folder in
                FolderRowView(folder: folder, viewModel: viewModel)
            }
        } header: {
            HStack {
                Text("Folders")
                Spacer()
                Button {
                    showNewFolderAlert = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.caption)
                }
            }
        }
        .alert("New Folder", isPresented: $showNewFolderAlert) {
            TextField("Folder name", text: $newFolderName)
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
            Button("Create") {
                let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    Task { @MainActor in await viewModel.createFolder(name: name, context: modelContext) }
                }
                newFolderName = ""
            }
        }
    }
}
