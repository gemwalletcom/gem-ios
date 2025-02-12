// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WordIndex: Hashable {
    public let index: Int
    public let word: String

    public init(index: Int, word: String) {
        self.index = index
        self.word = word
    }
}

extension WordIndex: Identifiable {
    public var id: String { String(index) }
}

public extension WordIndex {
    static func rows(for words: [String]) -> [[WordIndex]] {
        words
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
            .splitInSubArrays(into: words.count / 2)
    }
}
