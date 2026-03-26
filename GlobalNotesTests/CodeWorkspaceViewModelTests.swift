import XCTest
import SwiftData
@testable import Global_Notes

@MainActor
final class CodeWorkspaceViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = CodeWorkspaceViewModel()
        XCTAssertTrue(vm.snippets.isEmpty)
        XCTAssertNil(vm.selectedSnippet)
        XCTAssertTrue(vm.chatMessages.isEmpty)
        XCTAssertTrue(vm.userInput.isEmpty)
        XCTAssertFalse(vm.isGenerating)
    }

    func testCreateSnippet_addsToList() throws {
        let schema = Schema([CodeSnippetItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let vm = CodeWorkspaceViewModel()
        vm.createSnippet(context: context)

        XCTAssertEqual(vm.snippets.count, 1)
        XCTAssertNotNil(vm.selectedSnippet)
        XCTAssertEqual(vm.snippets.first?.title, "Untitled")
    }

    func testDeleteSnippet_removesFromList() throws {
        let schema = Schema([CodeSnippetItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let vm = CodeWorkspaceViewModel()
        vm.createSnippet(context: context)
        XCTAssertEqual(vm.snippets.count, 1)

        let snippet = vm.snippets[0]
        vm.deleteSnippet(snippet, context: context)
        XCTAssertEqual(vm.snippets.count, 0)
        XCTAssertNil(vm.selectedSnippet)
    }
}
