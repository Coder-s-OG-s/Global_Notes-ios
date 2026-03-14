import SwiftUI

struct TagInputView: View {
    @Binding var tags: [String]
    @Binding var showInput: Bool
    var onAdd: (String) -> Void
    var onRemove: (String) -> Void

    @State private var newTag = ""

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    TagChip(tag: tag) {
                        onRemove(tag)
                    }
                }

                if showInput {
                    HStack(spacing: 4) {
                        TextField("Add tag...", text: $newTag)
                            .font(.caption)
                            .frame(minWidth: 60, maxWidth: 120)
                            .onSubmit {
                                submitTag()
                            }

                        Button {
                            submitTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                }
            }
        }
    }

    private func submitTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onAdd(trimmed)
            newTag = ""
        }
    }
}

struct TagChip: View {
    let tag: String
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.system(size: 12, weight: .medium))

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.12), in: Capsule())
        .foregroundStyle(Color.accentColor)
    }
}
