import UIKit

/// Converts between HTML strings (Supabase/web format) and NSAttributedString (UITextView format)
enum HTMLConverter {

    // MARK: - HTML → NSAttributedString

    static func attributedString(from html: String) -> NSAttributedString {
        guard !html.isEmpty else {
            return NSAttributedString(string: "")
        }

        // Wrap in basic HTML with default styling
        let styledHTML = """
        <html>
        <head>
        <style>
            body {
                font-family: -apple-system, system-ui;
                font-size: 16px;
                color: \(UITraitCollection.current.userInterfaceStyle == .dark ? "#FFFFFF" : "#000000");
                line-height: 1.5;
            }
            code {
                font-family: Menlo, monospace;
                font-size: 14px;
                background-color: \(UITraitCollection.current.userInterfaceStyle == .dark ? "#2D2D2D" : "#F0F0F0");
                padding: 2px 4px;
                border-radius: 3px;
            }
            pre {
                background-color: \(UITraitCollection.current.userInterfaceStyle == .dark ? "#2D2D2D" : "#F0F0F0");
                padding: 12px;
                border-radius: 8px;
                overflow-x: auto;
            }
            blockquote {
                border-left: 3px solid #888;
                padding-left: 12px;
                margin-left: 0;
                color: #888;
            }
            img {
                max-width: 100%;
                height: auto;
            }
        </style>
        </head>
        <body>\(html)</body>
        </html>
        """

        guard let data = styledHTML.data(using: .utf8) else {
            return NSAttributedString(string: html.strippingHTML)
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed
        }

        return NSAttributedString(string: html.strippingHTML)
    }

    // MARK: - NSAttributedString → HTML

    static func html(from attributedString: NSAttributedString) -> String {
        guard attributedString.length > 0 else { return "" }

        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let htmlData = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: documentAttributes
            )
            if var htmlString = String(data: htmlData, encoding: .utf8) {
                // Clean up Apple's verbose HTML output
                htmlString = cleanAppleHTML(htmlString)
                return htmlString
            }
        } catch {
            print("HTML conversion error: \(error)")
        }

        return attributedString.string
    }

    /// Strips Apple's boilerplate from NSAttributedString HTML export
    private static func cleanAppleHTML(_ html: String) -> String {
        // Extract body content only
        if let bodyRange = html.range(of: "<body>"),
           let bodyEndRange = html.range(of: "</body>") {
            var body = String(html[bodyRange.upperBound..<bodyEndRange.lowerBound])
            // Remove excessive spans with only font-family
            body = body.replacingOccurrences(
                of: " style=\"font-family: '.AppleSystemUIFont';\"",
                with: ""
            )
            return body.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return html
    }

    // MARK: - Plain text preview

    static func plainText(from html: String, maxLength: Int = 150) -> String {
        html.strippingHTML.truncated(to: maxLength)
    }
}
