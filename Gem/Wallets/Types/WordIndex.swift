// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct WordIndex: Hashable {
    let index: Int
    let word: String
}

extension WordIndex: Identifiable {
    var id: String { String(index) }
}

extension WordIndex {
    static func rows(for words: [String]) -> [[WordIndex]] {
        words
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
            .splitInSubArrays(into: words.count / 2)
    }
}
