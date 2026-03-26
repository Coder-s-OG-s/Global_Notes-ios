import XCTest
@testable import Global_Notes

final class SlashCommandTests: XCTestCase {

    func testAllCases_hasExpectedCount() {
        XCTAssertGreaterThanOrEqual(SlashCommand.allCases.count, 5)
    }

    func testEachCommand_hasNonEmptyLabel() {
        for cmd in SlashCommand.allCases {
            XCTAssertFalse(cmd.label.isEmpty, "\(cmd) has empty label")
        }
    }

    func testEachCommand_hasNonEmptyIcon() {
        for cmd in SlashCommand.allCases {
            XCTAssertFalse(cmd.icon.isEmpty, "\(cmd) has empty icon")
        }
    }

    func testEachCommand_hasNonEmptyRawValue() {
        for cmd in SlashCommand.allCases {
            XCTAssertFalse(cmd.rawValue.isEmpty, "\(cmd) has empty rawValue")
        }
    }
}
