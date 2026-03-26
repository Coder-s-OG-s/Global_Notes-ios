import XCTest
@testable import Global_Notes

final class AttachmentServiceTests: XCTestCase {

    func testImageToHTML_validImage_returnsBase64HTML() {
        let image = UIImage(systemName: "star.fill")!
        let html = AttachmentService.imageToHTML(image)
        XCTAssertNotNil(html)
        XCTAssertTrue(html!.contains("data:image/jpeg;base64,"))
        XCTAssertTrue(html!.contains("<img"))
        XCTAssertTrue(html!.contains("max-width:100%"))
    }

    func testFileToHTML_returnsAttachmentDiv() {
        let html = AttachmentService.fileToHTML(filename: "report.pdf")
        XCTAssertTrue(html.contains("report.pdf"))
        XCTAssertTrue(html.contains("<div"))
    }
}
