import SwiftUI

/// Available app-wide color themes.
enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case amoledDark
    case natureGreen
    case corporateGray
    case minimalWhite

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:        return "System"
        case .amoledDark:    return "AMOLED Dark"
        case .natureGreen:   return "Nature Green"
        case .corporateGray: return "Corporate Gray"
        case .minimalWhite:  return "Minimal White"
        }
    }

    /// Optional forced color scheme. `nil` means follow the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system:        return nil
        case .amoledDark:    return .dark
        case .natureGreen:   return nil
        case .corporateGray: return nil
        case .minimalWhite:  return .light
        }
    }

    var accentColor: Color {
        switch self {
        case .system:        return .blue
        case .amoledDark:    return .purple
        case .natureGreen:   return .green
        case .corporateGray: return .gray
        case .minimalWhite:  return .indigo
        }
    }
}
