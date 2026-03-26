import SwiftUI

/// A form view for configuring and inserting an HTML table.
struct TableInsertionView: View {
    let onInsert: (String) -> Void

    @State private var rows = 3
    @State private var columns = 3
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Table Size") {
                    Stepper("Rows: \(rows)", value: $rows, in: 1...20)
                    Stepper("Columns: \(columns)", value: $columns, in: 1...10)
                }

                Section {
                    Button {
                        onInsert(generateHTML())
                        dismiss()
                    } label: {
                        Label("Insert Table", systemImage: "tablecells")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Insert Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func generateHTML() -> String {
        var html = "<table style=\"width:100%;border-collapse:collapse;margin:8px 0;\">"
        for r in 0..<rows {
            html += "<tr>"
            for _ in 0..<columns {
                let tag = r == 0 ? "th" : "td"
                html += "<\(tag) style=\"border:1px solid #ccc;padding:8px;text-align:left;\">&nbsp;</\(tag)>"
            }
            html += "</tr>"
        }
        html += "</table>"
        return html
    }
}
