import Foundation

/// View model powering the SmartCalendarView.
@MainActor
final class CalendarViewModel: ObservableObject {

    @Published var currentMonth: Int
    @Published var currentYear: Int
    @Published var selectedDate: Date?

    private let calendar = Calendar.current

    init() {
        let now = Date.now
        let components = Calendar.current.dateComponents([.month, .year], from: now)
        currentMonth = components.month ?? 1
        currentYear = components.year ?? 2026
    }

    // MARK: - Computed

    var daysInMonth: Int {
        let comps = DateComponents(year: currentYear, month: currentMonth)
        guard let date = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }

    var firstWeekdayOffset: Int {
        let comps = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let date = calendar.date(from: comps) else { return 0 }
        return calendar.component(.weekday, from: date) - 1
    }

    var monthName: String {
        let comps = DateComponents(year: currentYear, month: currentMonth)
        guard let date = calendar.date(from: comps) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    // MARK: - Navigation

    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        selectedDate = nil
    }

    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        selectedDate = nil
    }

    // MARK: - Helpers

    func date(for day: Int) -> Date {
        let comps = DateComponents(year: currentYear, month: currentMonth, day: day)
        return calendar.date(from: comps) ?? .now
    }

    func notesForDate(_ date: Date, notes: [NoteItem]) -> [NoteItem] {
        notes.filter { calendar.isDate($0.updatedAt, inSameDayAs: date) }
    }
}
