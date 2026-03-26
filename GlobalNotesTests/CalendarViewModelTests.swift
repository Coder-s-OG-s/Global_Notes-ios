import XCTest
@testable import Global_Notes

@MainActor
final class CalendarViewModelTests: XCTestCase {

    func testInitialState_isCurrentMonth() {
        let vm = CalendarViewModel()
        let cal = Calendar.current
        let now = Date()
        XCTAssertEqual(vm.currentMonth, cal.component(.month, from: now))
        XCTAssertEqual(vm.currentYear, cal.component(.year, from: now))
    }

    func testMonthName_returnsCorrectName() {
        let vm = CalendarViewModel()
        vm.currentMonth = 1
        XCTAssertEqual(vm.monthName, "January")
        vm.currentMonth = 12
        XCTAssertEqual(vm.monthName, "December")
    }

    func testNextMonth_incrementsMonth() {
        let vm = CalendarViewModel()
        vm.currentMonth = 3
        vm.currentYear = 2026
        vm.nextMonth()
        XCTAssertEqual(vm.currentMonth, 4)
        XCTAssertEqual(vm.currentYear, 2026)
    }

    func testNextMonth_decemberWrapsToJanuary() {
        let vm = CalendarViewModel()
        vm.currentMonth = 12
        vm.currentYear = 2026
        vm.nextMonth()
        XCTAssertEqual(vm.currentMonth, 1)
        XCTAssertEqual(vm.currentYear, 2027)
    }

    func testPreviousMonth_decrementsMonth() {
        let vm = CalendarViewModel()
        vm.currentMonth = 5
        vm.currentYear = 2026
        vm.previousMonth()
        XCTAssertEqual(vm.currentMonth, 4)
        XCTAssertEqual(vm.currentYear, 2026)
    }

    func testPreviousMonth_januaryWrapsToDecember() {
        let vm = CalendarViewModel()
        vm.currentMonth = 1
        vm.currentYear = 2026
        vm.previousMonth()
        XCTAssertEqual(vm.currentMonth, 12)
        XCTAssertEqual(vm.currentYear, 2025)
    }

    func testDaysInMonth_march2026_has31() {
        let vm = CalendarViewModel()
        vm.currentMonth = 3
        vm.currentYear = 2026
        XCTAssertEqual(vm.daysInMonth, 31)
    }

    func testDaysInMonth_february2024_has29() {
        let vm = CalendarViewModel()
        vm.currentMonth = 2
        vm.currentYear = 2024
        XCTAssertEqual(vm.daysInMonth, 29) // leap year
    }

    func testFirstWeekdayOffset_isValid() {
        let vm = CalendarViewModel()
        vm.currentMonth = 3
        vm.currentYear = 2026
        // firstWeekdayOffset should be 0-6
        XCTAssertGreaterThanOrEqual(vm.firstWeekdayOffset, 0)
        XCTAssertLessThanOrEqual(vm.firstWeekdayOffset, 6)
    }
}
