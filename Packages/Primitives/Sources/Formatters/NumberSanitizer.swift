// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct NumberSanitizer {
    private let decimalSeparator: Character
    private let allowedCharacters: CharacterSet

    public init(
        decimalSeparator: Character = Locale.current.decimalSeparator?.first ?? ".",
        allowedCharacters: CharacterSet = CharacterSet.decimalDigits
    ) {
        
        self.decimalSeparator = decimalSeparator
        self.allowedCharacters = allowedCharacters
            .union(CharacterSet(charactersIn: String(decimalSeparator)))
    }

    public func sanitize(_ input: String) -> String {
        let cleanedInput = cleanWhiteSpaceAndSymbols(input)
        let allowedCharacters = filterAllowedCharacters(cleanedInput)
        return sanitizeDecimalSeparator(allowedCharacters)
    }
    
    // MARK: - Private methods
    
    private func cleanWhiteSpaceAndSymbols(_ input: String) -> String {
        input.filter { !$0.isWhitespace && !$0.isSymbol }
    }
    
    private func filterAllowedCharacters(_ input: String) -> String {
        input.filter { $0.unicodeScalars.allSatisfy(allowedCharacters.contains) }
    }
    
    private func sanitizeDecimalSeparator(_ input: String) -> String {
        guard let separatorIndex = input.firstIndex(of: decimalSeparator) else {
            return input
        }

        let integerPart = input.prefix(upTo: separatorIndex)
        let decimalStartIndex = input.index(after: separatorIndex)
        let decimalPart = input[decimalStartIndex...].filter { $0 != decimalSeparator }

        return integerPart + String(decimalSeparator) + decimalPart
    }
}
