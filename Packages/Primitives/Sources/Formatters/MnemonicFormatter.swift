
import Foundation

public struct MnemonicFormatter {
    private static let separator = " "

    public static func fromArray(words: [String]) -> String {
        return words.joined(separator: separator)
    }

    public static func toArray(string: String) -> [String] {
        return string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: separator)
    }
}
