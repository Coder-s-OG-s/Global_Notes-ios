import XCTest
import SwiftUI
@testable import Global_Notes

/// Smoke tests — verifying every new view can be instantiated without crashing.
/// This catches missing initializers, broken property wrappers, and compile-time issues.
final class ViewInstantiationTests: XCTestCase {

    func testMediaPickerView_instantiates() {
        let _ = MediaPickerView { _ in }
    }

    func testFilePickerView_instantiates() {
        let _ = FilePickerView { _, _ in }
    }

    func testShareNoteView_instantiates() {
        let _ = ShareNoteView(title: "Test", content: "<p>Hello</p>")
    }

    func testTableInsertionView_instantiates() {
        let _ = TableInsertionView { _ in }
    }

    func testShapesPickerView_instantiates() {
        let _ = ShapesPickerView { _ in }
    }

    func testCustomTagCreatorView_instantiates() {
        let _ = CustomTagCreatorView { _, _ in }
    }

    func testAppThemeView_instantiates() {
        let _ = AppThemeView()
    }

    func testSlashCommandMenu_instantiates() {
        let _ = SlashCommandMenu { _ in }
    }

    func testAudioRecorderView_instantiates() {
        let _ = AudioRecorderView { _ in }
    }

    func testMailGeneratorView_instantiates() {
        let _ = MailGeneratorView()
    }

    func testSmartCalendarView_instantiates() {
        let _ = SmartCalendarView(notes: [])
    }

    func testSketchPadView_instantiates() {
        let _ = SketchPadView { _ in }
    }

    func testCodeWorkspaceView_instantiates() {
        let _ = CodeWorkspaceView()
    }

    func testCodeAIAssistantView_instantiates() {
        let _ = CodeAIAssistantView(
            code: "print(\"hello\")",
            language: "Swift",
            chatMessages: .constant([]),
            isGenerating: .constant(false)
        )
    }
}
