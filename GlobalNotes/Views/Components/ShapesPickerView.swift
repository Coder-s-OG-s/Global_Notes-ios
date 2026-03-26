import SwiftUI

/// A grid of basic shapes that insert SVG-in-HTML into the editor.
struct ShapesPickerView: View {
    let onInsert: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let shapes: [(name: String, icon: String)] = [
        ("Rectangle", "rectangle"),
        ("Circle", "circle"),
        ("Triangle", "triangle"),
        ("Star", "star"),
        ("Arrow", "arrow.right"),
        ("Line", "line.diagonal")
    ]

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                ForEach(shapes, id: \.name) { shape in
                    Button {
                        onInsert(svgHTML(for: shape.name))
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: shape.icon)
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)
                            Text(shape.name)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Insert Shape")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func svgHTML(for shape: String) -> String {
        let svg: String
        switch shape {
        case "Rectangle":
            svg = "<rect x=\"10\" y=\"10\" width=\"180\" height=\"100\" fill=\"#4A90D9\" rx=\"4\" />"
        case "Circle":
            svg = "<circle cx=\"100\" cy=\"60\" r=\"50\" fill=\"#E74C3C\" />"
        case "Triangle":
            svg = "<polygon points=\"100,10 190,110 10,110\" fill=\"#2ECC71\" />"
        case "Star":
            svg = "<polygon points=\"100,10 120,75 190,75 135,115 155,180 100,140 45,180 65,115 10,75 80,75\" fill=\"#F1C40F\" />"
        case "Arrow":
            svg = "<polygon points=\"10,60 140,60 140,30 190,75 140,120 140,90 10,90\" fill=\"#9B59B6\" />"
        case "Line":
            svg = "<line x1=\"10\" y1=\"10\" x2=\"190\" y2=\"110\" stroke=\"#333\" stroke-width=\"3\" />"
        default:
            svg = ""
        }
        return """
        <div style="margin:8px 0;">
        <svg width="200" height="120" viewBox="0 0 200 120" xmlns="http://www.w3.org/2000/svg">
        \(svg)
        </svg>
        </div>
        """
    }
}
