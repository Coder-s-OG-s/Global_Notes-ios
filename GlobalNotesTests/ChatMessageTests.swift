import XCTest
@testable import Global_Notes

final class ChatMessageTests: XCTestCase {

    func testInit_setsAllFields() {
        let msg = ChatMessage(role: "user", content: "Hello")
        XCTAssertEqual(msg.role, "user")
        XCTAssertEqual(msg.content, "Hello")
        XCTAssertNotNil(msg.id)
        XCTAssertNotNil(msg.timestamp)
    }

    func testTwoMessages_haveDifferentIds() {
        let m1 = ChatMessage(role: "user", content: "A")
        let m2 = ChatMessage(role: "assistant", content: "B")
        XCTAssertNotEqual(m1.id, m2.id)
    }
}
