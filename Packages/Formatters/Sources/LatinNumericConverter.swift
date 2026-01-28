// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

// Converts every Unicode decimal digit (General-Category “Nd”) to ASCII 0-9.
enum LatinNumericConverter {

    // Arabic punctuation we normalise explicitly
    private static let arabicDecimal: UnicodeScalar = "٫"   // U+066B
    private static let arabicGroup : UnicodeScalar = "٬"   // U+066C

    private static let nonLatinDigits: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "\u{0660}"..."\u{0669}") // Arabic-Indic digits
        set.insert(charactersIn: "\u{06F0}"..."\u{06F9}") // Extended Arabic digits
        set.insert(charactersIn: "\u{066B}\u{066C}") // Arabic decimal/thousands
        return set
    }()

    static func toLatinDigits(_ raw: String) -> String {
        guard raw.rangeOfCharacter(from: nonLatinDigits) != nil else { return raw }

        var output = String.UnicodeScalarView()
        output.reserveCapacity(raw.unicodeScalars.count)

        for scalar in raw.unicodeScalars {

            switch scalar {
            case arabicDecimal: output.append(".") // “٫” to dot
            case arabicGroup: continue // drop “٬”

            default:
                if scalar.properties.numericType == .decimal,
                   let value = scalar.properties.numericValue {
                    // Map any Nd digit (0-9) → ASCII
                    output.append(UnicodeScalar(48 + Int(value))!)
                } else {
                    output.append(scalar)
                }
            }
        }
        return String(output)
    }
}
