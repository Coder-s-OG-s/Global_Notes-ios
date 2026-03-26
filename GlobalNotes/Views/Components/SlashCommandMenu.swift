import SwiftUI

/// Available slash commands for the rich text editor.
enum SlashCommand: String, CaseIterable, Identifiable {
    case heading
    case paragraph
    case bulletList
    case image
    case table
    case codeBlock

    var id: String { rawValue }

    var label: String {
        switch self {
        case .heading:    return "Heading"
        case .paragraph:  return "Paragraph"
        case .bulletList: return "Bullet List"
        case .image:      return "Image"
        case .table:      return "Table"
        case .codeBlock:  return "Code Block"
        }
    }

    var icon: String {
        switch self {
        case .heading:    return "textformat.size"
        case .paragraph:  return "text.alignleft"
        case .bulletList: return "list.bullet"
        case .image:      return "photo"
        case .table:      return "tablecells"
        case .codeBlock:  return "chevron.left.forwardslash.chevron.right"
        }
    }
}

/// A menu overlay listing slash commands.
struct SlashCommandMenu: View {
    let onSelect: (SlashCommand) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(SlashCommand.allCases) { command in
                Button {
                    onSelect(command)
                    dismiss()
                } label: {
                    Label(command.label, systemImage: command.icon)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Insert Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
