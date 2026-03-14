import SwiftUI

/// Note theme picker matching web app's theme presets
struct ThemePicker: View {
    @Binding var selectedTheme: String?

    static let themes: [(id: String, name: String, bg: Color, accent: Color)] = [
        ("default", "Default", Color(.systemBackground), .accentColor),
        ("ocean", "Ocean", Color(hex: "0D1B2A"), Color(hex: "48CAE4")),
        ("forest", "Forest", Color(hex: "1B2D1B"), Color(hex: "52B788")),
        ("sunset", "Sunset", Color(hex: "2D1B1B"), Color(hex: "FF6B6B")),
        ("lavender", "Lavender", Color(hex: "1B1B2D"), Color(hex: "B8A9C9")),
        ("parchment", "Parchment", Color(hex: "F5F0E8"), Color(hex: "8B7355")),
        ("midnight", "Midnight", Color(hex: "0A0A1A"), Color(hex: "6C63FF")),
        ("rose", "Rose", Color(hex: "2D1B24"), Color(hex: "FF69B4")),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Self.themes, id: \.id) { theme in
                    Button {
                        selectedTheme = theme.id == "default" ? nil : theme.id
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(theme.bg)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Circle()
                                        .fill(theme.accent)
                                        .frame(width: 12, height: 12)
                                }
                                .overlay {
                                    if (selectedTheme ?? "default") == theme.id {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    }
                                }

                            Text(theme.name)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
