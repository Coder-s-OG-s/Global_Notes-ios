import UIKit

enum HapticManager {
    private static var isEnabled: Bool {
        // Default to true if the key hasn't been set
        UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
