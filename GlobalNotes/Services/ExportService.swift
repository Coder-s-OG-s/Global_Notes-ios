import UIKit

/// Exports notes to various formats — mirrors web app's exportImport.js
enum ExportService {

    // MARK: - Markdown

    static func toMarkdown(_ note: NoteItem) -> String {
        var md = "# \(note.title)\n\n"

        if !note.tags.isEmpty {
            md += "Tags: \(note.tags.joined(separator: ", "))\n\n"
        }

        md += "Created: \(note.createdAt.shortDisplay)\n"
        md += "Updated: \(note.updatedAt.shortDisplay)\n\n"
        md += "---\n\n"
        md += note.content.strippingHTML

        return md
    }

    // MARK: - Plain Text

    static func toPlainText(_ note: NoteItem) -> String {
        var text = "\(note.title)\n"
        text += String(repeating: "=", count: note.title.count) + "\n\n"

        if !note.tags.isEmpty {
            text += "Tags: \(note.tags.joined(separator: ", "))\n\n"
        }

        text += note.content.strippingHTML

        return text
    }

    // MARK: - PDF

    static func toPDF(_ note: NoteItem) -> Data? {
        let html = """
        <html>
        <head>
        <style>
            body { font-family: -apple-system, Helvetica; font-size: 14px; padding: 40px; color: #333; }
            h1 { font-size: 24px; margin-bottom: 8px; }
            .meta { color: #888; font-size: 12px; margin-bottom: 20px; }
            .tags { margin-bottom: 12px; }
            .tag { background: #e8e8e8; padding: 2px 8px; border-radius: 4px; font-size: 11px; }
            hr { border: none; border-top: 1px solid #ddd; margin: 16px 0; }
        </style>
        </head>
        <body>
            <h1>\(note.title)</h1>
            <div class="meta">\(note.updatedAt.shortDisplay)</div>
            \(note.tags.isEmpty ? "" : "<div class=\"tags\">" + note.tags.map { "<span class=\"tag\">\($0)</span>" }.joined(separator: " ") + "</div>")
            <hr>
            \(note.content)
        </body>
        </html>
        """

        let renderer = UIPrintPageRenderer()
        let formatter = UIMarkupTextPrintFormatter(markupText: html)

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let printableRect = pageRect.insetBy(dx: 36, dy: 36)

        renderer.setValue(pageRect, forKey: "paperRect")
        renderer.setValue(printableRect, forKey: "printableRect")
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }

    // MARK: - JSON (for backup/import)

    static func toJSON(_ notes: [NoteItem]) -> Data? {
        let exportNotes = notes.map { note in
            [
                "id": note.id,
                "title": note.title,
                "content": note.content,
                "tags": note.tags.joined(separator: ","),
                "folderId": note.folderId ?? "",
                "theme": note.theme ?? "",
                "isFavorite": note.isFavorite ? "true" : "false",
                "isArchived": note.isArchived ? "true" : "false",
                "createdAt": note.createdAt.iso8601String,
                "updatedAt": note.updatedAt.iso8601String
            ]
        }

        return try? JSONSerialization.data(withJSONObject: exportNotes, options: .prettyPrinted)
    }
}
