import Foundation

/// Cleans up raw transcription output by removing hallucination artifacts and filler words
struct TranscriptionOutputFilter {
    private static let hallucinationPatterns = [
        #"\[.*?\]"#,
        #"\(.*?\)"#,
        #"\{.*?\}"#,
    ]

    static func filter(_ text: String) -> String {
        var result = text

        // Remove <TAG>...</TAG> blocks
        let tagPattern = #"<([A-Za-z][A-Za-z0-9:_-]*)[^>]*>[\s\S]*?</\1>"#
        if let regex = try? NSRegularExpression(pattern: tagPattern) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
        }

        // Remove bracketed hallucinations
        for pattern in hallucinationPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            }
        }

        // Clean up excess whitespace
        result = result.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }
}
