// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct NumberInputNormalizer: Sendable {
    /// Symbol used as our standard decimal separator in the final output.
    private static let dot = "."

    /// Symbol used in some locales as decimal separator.
    private static let comma = ","

    /// Non-digit symbols frequently used for spacing or grouping (spaces, apostrophes, etc.)
    private static let unwantedSymbols = [" ", "'", "’", " ", "\u{00A0}"]

    /// Characters we allow to remain at the end of the string (digits, dot, comma, apostrophes, narrow space).
    private static let allowedTrailingCharacters: CharacterSet = {
        var set = CharacterSet.decimalDigits
        set.insert(charactersIn: dot + comma + "'" + " " + " ")
        return set
    }()

    /// Normalizes a raw `input` numeric string (with potential locale-specific separators or extra symbols)
    /// into a standard dot-based decimal format (e.g. `"1234.56"`) suitable for parsing.
    public static func normalize(_ input: String, locale: Locale) -> String {
        var str = input.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = str.unicodeScalars.last, !allowedTrailingCharacters.contains(last) {
            str.removeLast()
        }
        for sym in unwantedSymbols {
            str = str.replacingOccurrences(of: sym, with: "")
        }
        str = convertToStandardDecimal(str, locale: locale)
        str = removeLeadingZeros(str)
        return str.isEmpty ? .zero : str
    }

    /// Converts mixed usage of comma/dot separators to a single '.' decimal,
    /// guided by the locale's expected decimal separator.
    private static func convertToStandardDecimal(_ s: String, locale: Locale) -> String {
        let decSep = locale.decimalSeparator ?? dot
        var result = s

        if result.contains(dot) && result.contains(comma) {
            if decSep == dot {
                result = result.replacingOccurrences(of: comma, with: "")
                result = keepOnlyLastOccurrence(dot, from: result)
            } else {
                result = result.replacingOccurrences(of: dot, with: "")
                result = keepOnlyLastOccurrence(comma, from: result)
                result = result.replacingOccurrences(of: comma, with: dot)
            }
        } else if result.contains(dot) {
            if decSep == comma {
                if isSingleDotUsedAsGrouping(result) {
                    result = result.replacingOccurrences(of: dot, with: "")
                } else {
                    result = keepOnlyLastOccurrence(dot, from: result)
                }
            } else {
                result = keepOnlyLastOccurrence(dot, from: result)
            }
        } else if result.contains(comma) {
            if decSep == comma {
                result = keepOnlyLastOccurrence(comma, from: result)
                result = result.replacingOccurrences(of: comma, with: dot)
            } else {
                result = result.replacingOccurrences(of: comma, with: "")
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
    private static func keepOnlyLastOccurrence(_ symbol: String, from s: String) -> String {
        guard let lastIndex = s.lastIndex(of: Character(symbol)) else { return s }
        let prefix = s[s.startIndex..<lastIndex].replacingOccurrences(of: symbol, with: "")
        let suffix = s[lastIndex..<s.endIndex]
        return prefix + suffix
    }

    /// Removes leading zeros in the integer portion. If the entire integer portion
    /// is zeros, we keep a single "0". Preserves any fractional part.
    private static func removeLeadingZeros(_ s: String) -> String {
        let parts = s.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)

        let trimmedInt = parts[0].drop(while: { $0 == "0" })
        let integerString = trimmedInt.isEmpty ? "0" : String(trimmedInt)

        guard parts.count > 1 else {
            return integerString
        }
        return integerString + "." + parts[1]
    }
}
