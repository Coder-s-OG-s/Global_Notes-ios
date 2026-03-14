import SwiftUI
import SwiftData

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = NotesListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showProfile = false
    @State private var showSettings = false

    var body: some View {
        Group {
            if sizeClass == .regular {
                // iPad: 3-column layout
                NavigationSplitView {
                    SidebarView(viewModel: viewModel)
                        .toolbar {
                            sidebarToolbar
                        }
                } content: {
                    NotesListView(viewModel: viewModel)
                } detail: {
                    if let note = viewModel.selectedNote {
                        NoteEditorView(note: note, viewModel: viewModel)
                    } else {
                        EmptyEditorView()
                    }
                }
            } else {
                // iPhone: stacked navigation
                NavigationSplitView {
                    SidebarWithListView(viewModel: viewModel)
                        .toolbar {
                            sidebarToolbar
                        }
                } detail: {
                    if let note = viewModel.selectedNote {
                        NoteEditorView(note: note, viewModel: viewModel)
                    } else {
                        EmptyEditorView()
                    }
                }
            }
        }
        .task {
            await viewModel.loadData(context: modelContext)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    @ToolbarContentBuilder
    private var sidebarToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                Button { showProfile = true } label: {
                    Image(systemName: "person.circle")
                }
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

// MARK: - Sidebar (iPad)

struct SidebarView: View {
    @ObservedObject var viewModel: NotesListViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showNewFolderAlert = false
    @State private var newFolderName = ""

    var body: some View {
        List {
            // Library section
            Section("Library") {
                ForEach(LibraryFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.selectLibraryFilter(filter)
                    } label: {
                        Label {
                            Text(filter.rawValue)
                        } icon: {
                            Image(systemName: iconForFilter(filter))
                        }
                    }
                    .listRowBackground(
                        viewModel.libraryFilter == filter && viewModel.selectedFolderId == nil
                            ? Color.accentColor.opacity(0.12)
                            : Color.clear
                    )
                }
            }

            // Folders section
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
        }
        .listStyle(.sidebar)
        .navigationTitle("Global Notes")
        .alert("New Folder", isPresented: $showNewFolderAlert) {
            TextField("Folder name", text: $newFolderName)
            Button("Cancel", role: .cancel) { newFolderName = "" }
            Button("Create") {
                let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    Task { @MainActor in await viewModel.createFolder(name: name, context: modelContext) }
                }
                newFolderName = ""
            }
        }
    }

    func iconForFilter(_ filter: LibraryFilter) -> String {
        switch filter {
        case .all: return "tray.full"
        case .favorites: return "heart"
        case .archived: return "archivebox"
        }
    }
}

// MARK: - Combined Sidebar + List (iPhone)

struct SidebarWithListView: View {
    @ObservedObject var viewModel: NotesListViewModel

    var body: some View {
        NotesListView(viewModel: viewModel)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("Library") {
                            ForEach(LibraryFilter.allCases, id: \.self) { filter in
                                Button {
                                    viewModel.selectLibraryFilter(filter)
                                } label: {
                                    Label(filter.rawValue, systemImage: iconForFilter(filter))
                                }
                            }
                        }

                        if !viewModel.folders.isEmpty {
                            Section("Folders") {
                                Button {
                                    viewModel.selectFolder(nil)
                                } label: {
                                    Label("All Notes", systemImage: "tray.full")
                                }
                                ForEach(viewModel.folders, id: \.id) { folder in
                                    Button {
                                        viewModel.selectFolder(folder.id)
                                    } label: {
                                        Label(folder.name, systemImage: "folder")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
            }
    }

    func iconForFilter(_ filter: LibraryFilter) -> String {
        switch filter {
        case .all: return "tray.full"
        case .favorites: return "heart"
        case .archived: return "archivebox"
        }
    }
}

// MARK: - Empty State

struct EmptyEditorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.tertiary)

            Text("Select a note or create a new one")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
