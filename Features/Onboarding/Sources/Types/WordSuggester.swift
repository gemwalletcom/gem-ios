// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore

struct WordSuggester {
    func wordSuggestionCalculate(value: String) -> [String] {
        if value.last != Character.space, let word = value.split(separator: " ").last {
            let word = String(word)
            let suggestion = suggest(word: word)
            if suggestion.count == 1, suggestion[0] == word {
                return []
            }
            return suggestion
        }
        return []
    }
    
    func selectWordCalculate(input: String, word: String) -> String {
        var words = input.split(separator: " ").map { String($0) }
        if !words.isEmpty {
            words = words.dropLast()
            words.append(word)
        }
        return words.joined(separator: " ") + " "
    }
    
    private func suggest(word: String) -> [String] {
        let words = WalletCore.Mnemonic.suggest(prefix: word)
            .split(separator: " ")
            .map { String($0) }
        return Array(words)
    }
}
