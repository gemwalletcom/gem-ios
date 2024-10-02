// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore
import Settings
import SwiftUI
import Style

class VerifyPhraseViewModel: ObservableObject {
    
    private let words: [String]
    private let shuffledWords: [String]
    private let keystore: any Keystore

    @Binding private var navigationPath: NavigationPath

    @Published var wordsVerified: [String]
    @Published var wordsIndex: Int = 0
    @Published var buttonState = StateButtonStyle.State.disabled

    init(
        navigationPath: Binding<NavigationPath>,
        words: [String],
        keystore: any Keystore
    ) {
        _navigationPath = navigationPath
        self.words = words
        self.shuffledWords = words.shuffleInGroups(groupSize: 4)
        self.wordsVerified = Array(repeating: "", count: words.count)
        self.keystore = keystore
    }
    
    var title: String {
        "Confirm"
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
            wordsIndex += 1
        }
        // last word
        if wordsIndex == words.count {
            buttonState = .normal
        }
    }
    
    func isVerified(word: String) -> Bool {
        wordsVerified.contains(word)
    }
    
    func importWallet() throws -> Primitives.Wallet  {
        let name = WalletNameGenerator(type: .multicoin, keystore: keystore).name
        return try keystore.importWallet(
            name: name,
            type: .phrase(words: words, chains: AssetConfiguration.allChains)
        )
    }
}
