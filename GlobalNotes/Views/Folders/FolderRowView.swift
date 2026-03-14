import SwiftUI
import SwiftData

struct FolderRowView: View {
    let folder: FolderItem
    @ObservedObject var viewModel: NotesListViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var isRenaming = false
    @State private var newName = ""

    var body: some View {
        Button {
            viewModel.selectFolder(folder.id)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: viewModel.selectedFolderId == folder.id ? "folder.fill" : "folder")
                    .foregroundStyle(viewModel.selectedFolderId == folder.id ? Color.accentColor : .secondary)

                if isRenaming {
                    TextField("Folder name", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task {
                                await viewModel.renameFolder(folder, newName: newName, context: modelContext)
                            }
                            isRenaming = false
                        }
                } else {
                    Text(folder.name)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(viewModel.noteCount(for: folder.id))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }
        }
        .listRowBackground(
            viewModel.selectedFolderId == folder.id
                ? Color.accentColor.opacity(0.12)
                : Color.clear
        )
        .contextMenu {
            Button {
                newName = folder.name
                isRenaming = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                Task { @MainActor in await viewModel.deleteFolder(folder, context: modelContext) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
