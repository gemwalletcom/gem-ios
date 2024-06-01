// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

protocol SecretPhraseViewableModel {
    var title: String { get }
    var words: [String] { get }
    var rows: [[WordIndex]] { get }
    var presentWarning: Bool { get }
}

extension SecretPhraseViewableModel {
    var rows: [[WordIndex]] {
        return words
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
            .splitInSubArrays(into: words.count / 2)
    }
}

struct WordIndex: Hashable {
    let index: Int
    let word: String
}

extension WordIndex: Identifiable {
    var id: String { String(index) }
}
