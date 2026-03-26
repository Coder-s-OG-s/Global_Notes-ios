import Foundation
import UIKit

/// View model for AI-powered email generation.
@MainActor
final class MailGeneratorViewModel: ObservableObject {

    static let tones = ["Professional", "Casual", "Formal", "Friendly"]

    @Published var recipient: String = ""
    @Published var subject: String = ""
    @Published var tone: String = "Professional"
    @Published var keyPoints: String = ""
    @Published var generatedEmail: String = ""
    @Published var isGenerating: Bool = false
    @Published var error: String?

    func generateEmail() async {
        isGenerating = true
        error = nil

        let prompt = """
        Write an email with the following details:
        - To: \(recipient)
        - Subject: \(subject)
        - Tone: \(tone)
        - Key points to cover:
        \(keyPoints)

        Write only the email body. Do not include headers like "Subject:" or "To:". \
        Keep it concise and well-structured.
        """

        do {
            generatedEmail = try await GeminiService.shared.generateText(prompt: prompt)
        } catch {
            self.error = error.localizedDescription
        }

        isGenerating = false
    }

    func copyToClipboard() {
        UIPasteboard.general.string = generatedEmail
    }
}
