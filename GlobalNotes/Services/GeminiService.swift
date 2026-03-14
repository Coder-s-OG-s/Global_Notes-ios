import Foundation

/// Calls Google's Gemini API — mirrors web app's geminiAPI.js
@MainActor
final class GeminiService {
    static let shared = GeminiService()

    private init() {}

    private var apiURL: URL? {
        let key = AppConstants.geminiAPIKey
        guard !key.isEmpty else { return nil }
        return URL(string: "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(key)")
    }

    struct GeminiRequest: Encodable {
        let contents: [Content]

        struct Content: Encodable {
            let parts: [Part]

            struct Part: Encodable {
                let text: String
            }
        }
    }

    struct GeminiResponse: Decodable {
        let candidates: [Candidate]?

        struct Candidate: Decodable {
            let content: Content?

            struct Content: Decodable {
                let parts: [Part]?

                struct Part: Decodable {
                    let text: String?
                }
            }
        }
    }

    struct GeminiErrorResponse: Decodable {
        let error: ErrorDetail?

        struct ErrorDetail: Decodable {
            let message: String?
        }
    }

    func generateText(prompt: String) async throws -> String {
        guard let url = apiURL else {
            throw GeminiError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiRequest(
            contents: [
                .init(parts: [.init(text: prompt)])
            ]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                throw GeminiError.apiError(errorResponse.error?.message ?? "Unknown error")
            }
            throw GeminiError.apiError("Request failed with status \(httpResponse.statusCode)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        if let text = geminiResponse.candidates?.first?.content?.parts?.first?.text {
            return text
        }

        return "I'm sorry, I couldn't generate a response. Please try again."
    }

    enum GeminiError: LocalizedError {
        case notConfigured
        case invalidResponse
        case apiError(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured:
                return "AI is not configured. Please add GEMINI_API_KEY to Config.plist."
            case .invalidResponse:
                return "Invalid response from AI service."
            case .apiError(let message):
                return "AI Error: \(message)"
            }
        }
    }
}
