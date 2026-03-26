import SwiftUI

/// Provides basic syntax highlighting by applying colors to keywords, strings,
/// comments, and numbers.
enum SyntaxHighlighter {

    static func highlight(_ code: String, language: String) -> AttributedString {
        var attributed = AttributedString(code)

        let keywords = LanguageMap.keywords(for: language)
        let nsString = code as NSString

        // Comments — // to end-of-line
        applyPattern(#"//.*"#, to: &attributed, in: nsString, color: .gray)

        // Block comments
        applyPattern(#"/\*[\s\S]*?\*/"#, to: &attributed, in: nsString, color: .gray)

        // Strings (double-quoted)
        applyPattern(#""[^"\\]*(?:\\.[^"\\]*)*""#, to: &attributed, in: nsString, color: .green)

        // Strings (single-quoted)
        applyPattern(#"'[^'\\]*(?:\\.[^'\\]*)*'"#, to: &attributed, in: nsString, color: .green)

        // Numbers
        applyPattern(#"\b\d+(\.\d+)?\b"#, to: &attributed, in: nsString, color: .orange)

        // Keywords
        for keyword in keywords {
            applyPattern("\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b",
                         to: &attributed, in: nsString, color: .blue)
        }

        return attributed
    }

    // MARK: - Private

    private static func applyPattern(
        _ pattern: String,
        to attributed: inout AttributedString,
        in nsString: NSString,
        color: Color
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        let fullString = String(nsString)
        let matches = regex.matches(in: fullString, range: NSRange(location: 0, length: nsString.length))

        for match in matches {
            let nsRange = match.range
            guard nsRange.location != NSNotFound else { continue }
            // Convert NSRange to AttributedString range via string index
            guard let swiftRange = Range(nsRange, in: fullString) else { continue }
            let startOffset = fullString.distance(from: fullString.startIndex, to: swiftRange.lowerBound)
            let endOffset = fullString.distance(from: fullString.startIndex, to: swiftRange.upperBound)
            let attrStart = attributed.index(attributed.startIndex, offsetByCharacters: startOffset)
            let attrEnd = attributed.index(attributed.startIndex, offsetByCharacters: endOffset)
            attributed[attrStart..<attrEnd].foregroundColor = color
        }
    }
}
