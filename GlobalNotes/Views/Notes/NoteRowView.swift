import SwiftUI

struct NoteRowView: View {
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title row
            HStack(spacing: 6) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)

                if note.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.pink)
                        .accessibilityLabel("Favorite")
                }

                Spacer()

                if note.isArchived {
                    Image(systemName: "archivebox.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Archived")
                }
            }

            // Preview
            if !note.content.isEmpty {
                Text(HTMLConverter.plainText(from: note.content, maxLength: 80))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Bottom row: date + tags
            HStack(spacing: 8) {
                if !note.isSynced {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                        .accessibilityLabel("Not synced")
                }

                Text(note.updatedAt.shortDisplay)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                        }
                        if note.tags.count > 3 {
                            Text("+\(note.tags.count - 3)")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}
