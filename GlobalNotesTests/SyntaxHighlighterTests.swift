import XCTest
@testable import Global_Notes

final class SyntaxHighlighterTests: XCTestCase {

    func testHighlight_returnsAttributedString() {
        let result = SyntaxHighlighter.highlight("let x = 10", language: "Swift")
        XCTAssertFalse(String(result.characters).isEmpty)
    }

    func testHighlight_emptyCode_returnsEmpty() {
        let result = SyntaxHighlighter.highlight("", language: "Swift")
        XCTAssertTrue(String(result.characters).isEmpty)
    }

    func testHighlight_unknownLanguage_doesNotCrash() {
        let result = SyntaxHighlighter.highlight("print('hello')", language: "UnknownLang")
        XCTAssertFalse(String(result.characters).isEmpty)
    }
}
