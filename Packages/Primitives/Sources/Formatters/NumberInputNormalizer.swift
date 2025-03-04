// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct NumberInputNormalizer: Sendable {
    private static let dot = "."
    private static let comma = ","
    private static let extraSymbols = [" ", "'", "’", " ", "\u{00A0}"]

    private static let allowedTrailingCharacters: CharacterSet = {
        var set = CharacterSet.decimalDigits
        set.insert(charactersIn: dot + comma + "'" + " " + " ")
        return set
    }()

    // normalize string from any locale to default decimal locale (US)
    public static func normalize(_ input: String, locale: Locale) -> String {
        var str = input.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = str.unicodeScalars.last, !allowedTrailingCharacters.contains(last) {
            str.removeLast()
        }
        for sym in extraSymbols {
            str = str.replacingOccurrences(of: sym, with: "")
        }
        str = convertToStandardDecimal(str, locale: locale)
        str = removeLeadingZeros(str)
        return str.isEmpty ? "0" : str
    }

    private static func convertToStandardDecimal(_ s: String, locale: Locale) -> String {
        let decSep = locale.decimalSeparator ?? dot
        var res = s

        if res.contains(dot) && res.contains(comma) {
            if decSep == dot {
                res = res.replacingOccurrences(of: comma, with: "")
                res = removeAllButLast(dot, from: res)
            } else {
                res = res.replacingOccurrences(of: dot, with: "")
                res = removeAllButLast(comma, from: res)
                res = res.replacingOccurrences(of: comma, with: dot)
            }
        } else if res.contains(dot) {
            if decSep == comma {
                if singleDotIsGrouping(res) {
                    res = res.replacingOccurrences(of: dot, with: "")
                } else {
                    res = removeAllButLast(dot, from: res)
                }
            } else {
                res = removeAllButLast(dot, from: res)
            }
        } else if res.contains(comma) {
            if decSep == comma {
                res = removeAllButLast(comma, from: res)
                res = res.replacingOccurrences(of: comma, with: dot)
            } else {
                res = res.replacingOccurrences(of: comma, with: "")
            }
        }
        return res
    }

    private static func singleDotIsGrouping(_ s: String) -> Bool {
        guard let idx = s.firstIndex(of: Character(dot)), s.lastIndex(of: Character(dot)) == idx else { return false }
        let after = s[s.index(after: idx)...]
        let before = s[..<idx]
        return after.count == 3 && after.allSatisfy(\.isNumber)
            && !before.isEmpty && before.allSatisfy(\.isNumber)
    }

    private static func removeAllButLast(_ symbol: String, from s: String) -> String {
        guard let lastIndex = s.lastIndex(of: Character(symbol)) else { return s }
        let prefix = s[s.startIndex..<lastIndex].replacingOccurrences(of: symbol, with: "")
        let suffix = s[lastIndex..<s.endIndex]
        return prefix + suffix
    }

    private static func removeLeadingZeros(_ s: String) -> String {
        guard let dotPos = s.firstIndex(of: ".") else {
            let trimmed = s.drop(while: { $0 == "0" })
            return trimmed.isEmpty ? "0" : String(trimmed)
        }
        let intPart = s[..<dotPos]
        let fracPart = s[s.index(after: dotPos)...]
        let trimmedInt = intPart.drop(while: { $0 == "0" })
        return (trimmedInt.isEmpty ? "0" : String(trimmedInt)) + "." + fracPart
    }
}
