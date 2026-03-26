import XCTest
import SwiftUI
@testable import Global_Notes

final class AppThemeTests: XCTestCase {

    func testAllCases_hasExpectedCount() {
        XCTAssertEqual(AppTheme.allCases.count, 5)
    }

    func testSystem_hasNilColorScheme() {
        XCTAssertNil(AppTheme.system.colorScheme)
    }

    func testAmoledDark_hasDarkColorScheme() {
        XCTAssertEqual(AppTheme.amoledDark.colorScheme, .dark)
    }

    func testMinimalWhite_hasLightColorScheme() {
        XCTAssertEqual(AppTheme.minimalWhite.colorScheme, .light)
    }

    func testEachTheme_hasDisplayName() {
        for theme in AppTheme.allCases {
            XCTAssertFalse(theme.displayName.isEmpty, "\(theme) has empty displayName")
        }
    }

    func testRawValueRoundTrip() {
        for theme in AppTheme.allCases {
            let raw = theme.rawValue
            let restored = AppTheme(rawValue: raw)
            XCTAssertEqual(restored, theme)
        }
    }
}
