import SwiftUI
import UIKit

/// Formatting toolbar for the rich text editor
struct FormattingToolbar: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                FormatButton(icon: "bold", label: "Bold") {
                    applyFormatting(.bold)
                }
                FormatButton(icon: "italic", label: "Italic") {
                    applyFormatting(.italic)
                }
                FormatButton(icon: "underline", label: "Underline") {
                    applyFormatting(.underline)
                }
                FormatButton(icon: "strikethrough", label: "Strikethrough") {
                    applyFormatting(.strikethrough)
                }

                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)

                FormatButton(icon: "text.badge.plus", label: "Heading") {
                    applyFormatting(.heading)
                }
                FormatButton(icon: "list.bullet", label: "Bullet List") {
                    applyFormatting(.bulletList)
                }
                FormatButton(icon: "list.number", label: "Numbered List") {
                    applyFormatting(.numberedList)
                }

                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 4)

                FormatButton(icon: "chevron.left.forwardslash.chevron.right", label: "Code") {
                    applyFormatting(.code)
                }
                FormatButton(icon: "text.quote", label: "Quote") {
                    applyFormatting(.quote)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color(.secondarySystemBackground).opacity(0.5))
    }

    // MARK: - Format Actions

    enum FormatType {
        case bold, italic, underline, strikethrough, heading, bulletList, numberedList, code, quote
    }

    private func applyFormatting(_ type: FormatType) {
        guard let textView = findFirstResponderTextView() else { return }
        let range = textView.selectedRange
        guard range.length > 0 else {
            HapticManager.notification(.warning)
            return
        }

        let mutableAttr = NSMutableAttributedString(attributedString: textView.attributedText)

        switch type {
        case .bold:
            toggleTrait(.traitBold, in: mutableAttr, range: range)
        case .italic:
            toggleTrait(.traitItalic, in: mutableAttr, range: range)
        case .underline:
            let hasUnderline = mutableAttr.attribute(.underlineStyle, at: range.location, effectiveRange: nil) != nil
            if hasUnderline {
                mutableAttr.removeAttribute(.underlineStyle, range: range)
            } else {
                mutableAttr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        case .strikethrough:
            let hasStrike = mutableAttr.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) != nil
            if hasStrike {
                mutableAttr.removeAttribute(.strikethroughStyle, range: range)
            } else {
                mutableAttr.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        case .heading:
            let headingFont = UIFont.systemFont(ofSize: 22, weight: .bold)
            mutableAttr.addAttribute(.font, value: headingFont, range: range)
        case .bulletList:
            insertPrefix("• ", in: mutableAttr, range: range)
        case .numberedList:
            insertPrefix("1. ", in: mutableAttr, range: range)
        case .code:
            let codeFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            mutableAttr.addAttribute(.font, value: codeFont, range: range)
            mutableAttr.addAttribute(.backgroundColor, value: UIColor.secondarySystemFill, range: range)
        case .quote:
            insertPrefix("> ", in: mutableAttr, range: range)
        }

        textView.attributedText = mutableAttr
        textView.selectedRange = range

        // Notify delegate of change
        textView.delegate?.textViewDidChange?(textView)

        HapticManager.impact(.light)
    }

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in attrStr: NSMutableAttributedString, range: NSRange) {
        attrStr.enumerateAttribute(.font, in: range) { value, subRange, _ in
            guard let font = value as? UIFont else { return }
            var traits = font.fontDescriptor.symbolicTraits
            if traits.contains(trait) {
                traits.remove(trait)
            } else {
                traits.insert(trait)
            }
            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                attrStr.addAttribute(.font, value: newFont, range: subRange)
            }
        }
    }

    private func insertPrefix(_ prefix: String, in attrStr: NSMutableAttributedString, range: NSRange) {
        let text = attrStr.attributedSubstring(from: range).string
        let lines = text.components(separatedBy: "\n")
        let prefixed = lines.map { prefix + $0 }.joined(separator: "\n")
        attrStr.replaceCharacters(in: range, with: prefixed)
    }

    private func findFirstResponderTextView() -> UITextView? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return nil }
        return findTextView(in: window)
    }

    private func findTextView(in view: UIView) -> UITextView? {
        if let tv = view as? UITextView, tv.isFirstResponder { return tv }
        for sub in view.subviews {
            if let found = findTextView(in: sub) { return found }
        }
        return nil
    }
}

// MARK: - Format Button

struct FormatButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(label)
    }
}
