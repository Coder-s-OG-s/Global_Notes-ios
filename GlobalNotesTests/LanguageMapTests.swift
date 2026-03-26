import XCTest
@testable import Global_Notes

final class LanguageMapTests: XCTestCase {

    func testAllLanguages_isNotEmpty() {
        XCTAssertFalse(LanguageMap.languages.isEmpty)
        XCTAssertGreaterThanOrEqual(LanguageMap.languages.count, 20)
    }

    func testAllLanguages_containsCommonLanguages() {
        let langs = LanguageMap.languages
        XCTAssertTrue(langs.contains("Swift"))
        XCTAssertTrue(langs.contains("Python"))
        XCTAssertTrue(langs.contains("JavaScript"))
        XCTAssertTrue(langs.contains("Go"))
        XCTAssertTrue(langs.contains("Rust"))
    }

    func testKeywords_forSwift_returnsKeywords() {
        let keywords = LanguageMap.keywords(for: "Swift")
        XCTAssertFalse(keywords.isEmpty)
        XCTAssertTrue(keywords.contains("func") || keywords.contains("let") || keywords.contains("var"))
    }

    func testKeywords_forUnknownLanguage_returnsEmptyOrGeneric() {
        let keywords = LanguageMap.keywords(for: "BrainF**k")
        // Should not crash, can return empty
        XCTAssertNotNil(keywords)
    }
}
