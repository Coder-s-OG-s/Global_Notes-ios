import XCTest
@testable import Global_Notes

@MainActor
final class MailGeneratorViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = MailGeneratorViewModel()
        XCTAssertTrue(vm.recipient.isEmpty)
        XCTAssertTrue(vm.subject.isEmpty)
        XCTAssertEqual(vm.tone, "Professional")
        XCTAssertTrue(vm.keyPoints.isEmpty)
        XCTAssertTrue(vm.generatedEmail.isEmpty)
        XCTAssertFalse(vm.isGenerating)
        XCTAssertNil(vm.error)
    }

    func testCopyToClipboard_copiesGeneratedEmail() {
        let vm = MailGeneratorViewModel()
        vm.generatedEmail = "Hello, this is a test email."
        vm.copyToClipboard()
        let clipboard = UIPasteboard.general.string
        XCTAssertEqual(clipboard, "Hello, this is a test email.")
    }
}
