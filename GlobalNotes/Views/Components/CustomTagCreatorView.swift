import SwiftUI

/// A sheet for creating a custom colored tag.
struct CustomTagCreatorView: View {
    let onAdd: (String, String) -> Void

    @State private var tagName = ""
    @State private var selectedColor = "#4A90D9"
    @Environment(\.dismiss) private var dismiss

    private let colorSwatches: [String] = [
        "#E74C3C", "#E67E22", "#F1C40F", "#2ECC71",
        "#1ABC9C", "#3498DB", "#4A90D9", "#9B59B6",
        "#8E44AD", "#34495E", "#95A5A6", "#E91E63"
    ]

    private let columns = [GridItem(.adaptive(minimum: 44))]

    var body: some View {
        NavigationStack {
            Form {
                Section("Tag Name") {
                    TextField("Enter tag name", text: $tagName)
                        .autocorrectionDisabled()
                }

                Section("Color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(colorSwatches, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == hex {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button {
                        let name = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        onAdd(name, selectedColor)
                        dismiss()
                    } label: {
                        Label("Add Tag", systemImage: "tag.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}