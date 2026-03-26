import XCTest
@testable import Global_Notes

@MainActor
final class AudioRecorderServiceTests: XCTestCase {

    func testInitialState() {
        let service = AudioRecorderService()
        XCTAssertFalse(service.isRecording)
        XCTAssertEqual(service.duration, 0)
        XCTAssertNil(service.errorMessage)
    }

    func testCancelRecording_resetsState() {
        let service = AudioRecorderService()
        service.cancelRecording()
        XCTAssertFalse(service.isRecording)
        XCTAssertEqual(service.duration, 0)
    }

    func testStopRecording_withoutStarting_returnsNil() {
        let service = AudioRecorderService()
        let url = service.stopRecording()
        XCTAssertNil(url)
    }
}
