import SwiftUI
import PencilKit

/// A simple sketch pad backed by PencilKit.
struct SketchPadView: View {
    let onSave: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()

    var body: some View {
        NavigationStack {
            CanvasRepresentable(canvasView: $canvasView)
                .navigationTitle("Sketch")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
                            let image = renderer.image { _ in
                                canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
                            }
                            onSave(image)
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Clear") {
                            canvasView.drawing = PKDrawing()
                        }
                    }
                }
        }
    }
}

// MARK: - PencilKit Canvas Wrapper

private struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .label, width: 3)
        canvasView.backgroundColor = .systemBackground
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
