import SwiftUI
import UniformTypeIdentifiers

/// A UIViewControllerRepresentable that wraps UIDocumentPickerViewController.
struct FilePickerView: UIViewControllerRepresentable {
    let onFilePicked: (URL, String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onFilePicked: onFilePicked) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilePicked: (URL, String) -> Void

        init(onFilePicked: @escaping (URL, String) -> Void) {
            self.onFilePicked = onFilePicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let filename = url.lastPathComponent
            onFilePicked(url, filename)
        }
    }
}
