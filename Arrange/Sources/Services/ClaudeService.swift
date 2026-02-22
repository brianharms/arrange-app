import Foundation

class ClaudeService {

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Request: Codable {
        let model: String
        let max_tokens: Int
        let messages: [Message]
        let system: String
    }

    struct Response: Codable {
        let content: [ContentBlock]

        struct ContentBlock: Codable {
            let type: String
            let text: String?
        }
    }

    func modify(
        preset: LayoutPreset,
        instruction: String,
        apiKey: String
    ) async throws -> LayoutPreset {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let presetJSON = String(data: try encoder.encode(preset), encoding: .utf8) ?? "{}"

        let systemPrompt = """
        You are a window layout assistant. You receive a JSON layout preset and a user instruction.
        Modify the preset according to the instruction and return ONLY the modified JSON.
        The layout has columns (each with a flex value) containing apps (each with an id and flex value).
        Flex values control proportional sizing. Higher flex = larger.
        alignRows controls whether rows across columns are aligned.
        Return valid JSON only, no markdown, no explanation.
        """

        let userMessage = """
        Current layout:
        \(presetJSON)

        Instruction: \(instruction)

        Return the modified layout JSON only.
        """

        let request = Request(
            model: "claude-sonnet-4-6",
            max_tokens: 2048,
            messages: [Message(role: "user", content: userMessage)],
            system: systemPrompt
        )

        let requestData = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.httpBody = requestData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ClaudeError.apiError(statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        let apiResponse = try JSONDecoder().decode(Response.self, from: data)

        guard let text = apiResponse.content.first?.text else {
            throw ClaudeError.emptyResponse
        }

        // Extract JSON from response (handle potential markdown wrapping)
        let jsonText = extractJSON(from: text)

        guard let jsonData = jsonText.data(using: .utf8) else {
            throw ClaudeError.invalidJSON
        }

        let modified = try JSONDecoder().decode(LayoutPreset.self, from: jsonData)
        return modified
    }

    private func extractJSON(from text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove markdown code fences if present
        if t.hasPrefix("```") {
            if let start = t.firstIndex(of: "\n") {
                t = String(t[t.index(after: start)...])
            }
            if t.hasSuffix("```") {
                t = String(t.dropLast(3))
            }
            t = t.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return t
    }

    enum ClaudeError: LocalizedError {
        case apiError(Int, String)
        case emptyResponse
        case invalidJSON

        var errorDescription: String? {
            switch self {
            case .apiError(let code, let body):
                return "API error \(code): \(body.prefix(200))"
            case .emptyResponse:
                return "Empty response from Claude"
            case .invalidJSON:
                return "Could not parse layout JSON"
            }
        }
    }
}
