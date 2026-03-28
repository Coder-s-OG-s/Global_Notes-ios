import SwiftUI

/// Calendar view that highlights dates containing notes.
struct SmartCalendarView: View {
    let notes: [NoteItem]

    @StateObject private var viewModel = CalendarViewModel()

    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation
                HStack {
                    Button { viewModel.previousMonth() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel("Previous month")
                    Spacer()
                    Text("\(viewModel.monthName) \(String(viewModel.currentYear))")
                        .font(.headline)
                    Spacer()
                    Button { viewModel.nextMonth() } label: {
                        Image(systemName: "chevron.right")
                    }
                    .accessibilityLabel("Next month")
                }
                .padding()

                // Day headers
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Date cells
                LazyVGrid(columns: columns, spacing: 8) {
                    // Leading empty cells
                    ForEach(0..<viewModel.firstWeekdayOffset, id: \.self) { _ in
                        Text("")
                    }

                    ForEach(1...viewModel.daysInMonth, id: \.self) { day in
                        let date = viewModel.date(for: day)
                        let hasNotes = !viewModel.notesForDate(date, notes: notes).isEmpty
                        let isSelected = viewModel.selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false

                        Button {
                            viewModel.selectedDate = date
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(day)")
                                    .font(.body)
                                    .fontWeight(isSelected ? .bold : .regular)
                                if hasNotes {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 6, height: 6)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Divider().padding(.top, 8)

                // Notes for selected date
                if let selected = viewModel.selectedDate {
                    let filtered = viewModel.notesForDate(selected, notes: notes)
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "No Notes",
                            systemImage: "note.text",
                            description: Text("No notes for this date.")
                        )
                    } else {
                        List(filtered, id: \.id) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.updatedAt, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .listStyle(.plain)
                    }
                } else {
                    ContentUnavailableView(
                        "Select a Date",
                        systemImage: "calendar",
                        description: Text("Tap a date to see its notes.")
                    )
                }
            }
            .navigationTitle(viewModel.monthName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
