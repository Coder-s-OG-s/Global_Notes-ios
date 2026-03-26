import SwiftUI

/// A picker view for selecting the app-wide theme.
struct AppThemeView: View {
    @AppStorage("appTheme") private var selectedTheme: String = AppTheme.system.rawValue

    private let columns = [GridItem(.adaptive(minimum: 140))]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Theme")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AppTheme.allCases) { theme in
                    let isSelected = selectedTheme == theme.rawValue

                    Button {
                        selectedTheme = theme.rawValue
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(theme.accentColor.gradient)
                                .frame(height: 60)
                                .overlay(alignment: .topTrailing) {
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(6)
                                    }
                                }

                            Text(theme.displayName)
                                .font(.caption)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .foregroundStyle(isSelected ? theme.accentColor : .primary)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
