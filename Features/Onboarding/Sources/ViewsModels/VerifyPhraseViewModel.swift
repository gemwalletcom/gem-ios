// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore
import Settings
import SwiftUI
import Style
import Localization
import PrimitivesComponents

class VerifyPhraseViewModel: ObservableObject {
    
    private let words: [String]
    private let shuffledWords: [String]
    private let keystore: any Keystore

    @Published var wordsVerified: [String]
    @Published var wordsIndex: Int = 0
    @Published var buttonState = StateButtonStyle.State.disabled
    private var selectedIndexes = Set<WordIndex>()

    init(
        words: [String],
        keystore: any Keystore
    ) {
        self.words = words
        self.shuffledWords = words.shuffleInGroups(groupSize: 4)
        self.wordsVerified = Array(repeating: "", count: words.count)
        self.keystore = keystore
    }
    
    var title: String {
        Localized.VerifyPhrase.title
    }
    
    var rows: [[WordIndex]] {
        return wordsVerified
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
            .splitInSubArrays(into: wordsVerified.count / 2)
    }
    
    var rowsSections: [[WordIndex]] {
        return selectRows.chunks(4)
    }
    
    var selectRows: [WordIndex] {
        return shuffledWords
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
    }
    
    func pickWord(index: WordIndex) {
        if words[wordsIndex] == index.word {
            wordsVerified[wordsIndex] = index.word
            selectedIndexes.insert(index)
            wordsIndex += 1
        }
        // last word
        if wordsIndex == words.count {
            buttonState = .normal
        }
    }
    
    func isVerified(index: WordIndex) -> Bool {
        selectedIndexes.contains(index)
    }
    
    func importWallet() throws -> Primitives.Wallet  {
        let name = WalletNameGenerator(type: .multicoin, keystore: keystore).name
        return try keystore.importWallet(
            name: name,
            type: .phrase(words: words, chains: AssetConfiguration.allChains)
        )
    }
}
