import SwiftUI
import UIKit

/// Native rich text editor using UITextView — handles HTML content from Supabase/web app
struct RichTextEditor: UIViewRepresentable {
    @Binding var htmlContent: String
    var onContentChange: () -> Void
    @AppStorage("editorFontSize") private var editorFontSize = 16.0

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: editorFontSize)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.allowsEditingTextAttributes = true
        textView.autocorrectionType = .default
        textView.smartQuotesType = .yes
        textView.smartDashesType = .yes

        // Load initial content
        if !htmlContent.isEmpty {
            textView.attributedText = HTMLConverter.attributedString(from: htmlContent)
        }

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if the HTML actually changed externally (e.g., note switch)
        guard context.coordinator.shouldUpdateContent else { return }

        let newAttributed = HTMLConverter.attributedString(from: htmlContent)
        let currentHTML = HTMLConverter.html(from: textView.attributedText)

        // Avoid unnecessary updates that would reset cursor position
        if currentHTML != htmlContent {
            let selectedRange = textView.selectedRange
            textView.attributedText = newAttributed
            // Restore cursor if possible
            if selectedRange.location <= textView.text.count {
                textView.selectedRange = selectedRange
            }
        }
        context.coordinator.shouldUpdateContent = false
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var shouldUpdateContent = true

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            shouldUpdateContent = false
            let html = HTMLConverter.html(from: textView.attributedText)
            parent.htmlContent = html
            parent.onContentChange()
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            shouldUpdateContent = false
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            shouldUpdateContent = true
        }
    }
}
