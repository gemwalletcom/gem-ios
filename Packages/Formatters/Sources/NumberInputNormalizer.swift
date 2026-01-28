// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct NumberInputNormalizer: Sendable {
    /// Symbol used as our standard decimal separator in the final output.
    private static let dot = "."

    /// Symbol used in some locales as decimal separator.
    private static let comma = ","

    /// Non-digit symbols frequently used for spacing or grouping (spaces, apostrophes, etc.)
    private static let unwantedSymbols = [" ", "'", "’", " ", "\u{00A0}"]

    /// Characters we allow to remain at the end of the string (digits, dot, comma, apostrophes, narrow space).
    private static let allowedTrailingCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: dot + comma + "'" + " " + " "))

    /// Normalizes a raw `input` numeric string (with potential locale-specific separators or extra symbols)
    /// into a standard dot-based decimal format (e.g. `"1234.56"`) suitable for parsing.
    static func normalize(_ input: String, locale: Locale) -> String {
        var string = LatinNumericConverter.toLatinDigits(input).trimmingCharacters(in: .whitespacesAndNewlines)

        while let last = string.unicodeScalars.last, !allowedTrailingCharacters.contains(last) {
            string.removeLast()
        }
        for sym in unwantedSymbols {
            string = string.replacingOccurrences(of: sym, with: String.empty)
        }
        string = convertToStandardDecimal(string, locale: locale)
        string = removeLeadingZeros(string)
        return string.isEmpty ? .zero : string
    }

    /// Converts mixed usage of comma/dot separators to a single '.' decimal,
    /// guided by the locale's expected decimal separator.
    private static func convertToStandardDecimal(_ original: String, locale: Locale) -> String {
        let decimalSeparator = locale.decimalSeparator ?? dot
        var result = original

        let hasDot = result.contains(dot)
        let hasComma = result.contains(comma)

        // Both dot and comma present
        if hasDot && hasComma {
            if decimalSeparator == dot {
                result = result.replacingOccurrences(of: comma, with: String.empty)
                result = keepOnlyLastOccurrence(of: dot, in: result)
            } else {
                result = result.replacingOccurrences(of: dot, with: String.empty)
                result = keepOnlyLastOccurrence(of: comma, in: result)
                result = result.replacingOccurrences(of: comma, with: dot)
            }
        }
        // Only dot
        else if hasDot {
            if decimalSeparator == comma && isSingleDotUsedAsGrouping(result) {
                result = result.replacingOccurrences(of: dot, with: String.empty)
            } else {
                result = keepOnlyLastOccurrence(of: dot, in: result)
            }
        }
        // Only comma
        else if hasComma {
            if decimalSeparator == comma {
                result = keepOnlyLastOccurrence(of: comma, in: result)
                result = result.replacingOccurrences(of: comma, with: dot)
            } else {
                result = result.replacingOccurrences(of: comma, with: String.empty)
            }
        }

        return result
    }

    /// Returns true if there's exactly one '.' in the string and it's placed as a grouping mark,
    /// i.e. "1.234" has exactly three digits after '.', all numeric.
    private static func isSingleDotUsedAsGrouping(_ s: String) -> Bool {
        guard let idx = s.firstIndex(of: Character(dot)), s.lastIndex(of: Character(dot)) == idx else { return false }
        let after = s[s.index(after: idx)...]
        let before = s[..<idx]
        return after.count == 3 && after.allSatisfy(\.isNumber)
            && !before.isEmpty && before.allSatisfy(\.isNumber)
    }

    /// Removes all occurrences of `symbol` except for the last one.
    /// Example: "1.234.56" => "1234.56" (keeping only the final '.').
    private static func keepOnlyLastOccurrence(of symbol: String, in s: String) -> String {
        guard let lastIndex = s.lastIndex(of: Character(symbol)) else { return s }
        let prefix = s[s.startIndex..<lastIndex].replacingOccurrences(of: symbol, with: String.empty)
        let suffix = s[lastIndex..<s.endIndex]
        return prefix + suffix
    }

    /// Removes leading zeros in the integer portion. If the entire integer portion
    /// is zeros, we keep a single "0". Preserves any fractional part.
    private static func removeLeadingZeros(_ s: String) -> String {
        let parts = s.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let trimmedInt = parts[0].drop { $0 == "0" }
        let integerPart = trimmedInt.isEmpty ? "0" : String(trimmedInt)
        return parts.count < 2 ? integerPart : integerPart + "." + parts[1]
    }
}
