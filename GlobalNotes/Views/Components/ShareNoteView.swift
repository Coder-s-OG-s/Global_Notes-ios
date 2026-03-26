import SwiftUI

/// A UIViewControllerRepresentable wrapping UIActivityViewController for sharing notes.
struct ShareNoteView: UIViewControllerRepresentable {
    let title: String
    let content: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let plainText = content.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        let shareText = "\(title)\n\n\(plainText)"
        return UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
