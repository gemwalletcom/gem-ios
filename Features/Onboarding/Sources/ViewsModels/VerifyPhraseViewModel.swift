// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletService
import SwiftUI
import Style
import Localization
import PrimitivesComponents

class VerifyPhraseViewModel: ObservableObject {
    
    private let words: [String]
    private let shuffledWords: [String]
    private let walletService: WalletService
    private let onFinish: VoidAction

    @Published var wordsVerified: [String]
    @Published var wordsIndex: Int = 0
    @Published var buttonState = StateButtonStyle.State.disabled
    private var selectedIndexes = Set<WordIndex>()

    init(
        words: [String],
        walletService: WalletService,
        onFinish: VoidAction
    ) {
        self.words = words
        self.shuffledWords = words.shuffleInGroups(groupSize: 4)
        self.wordsVerified = Array(repeating: "", count: words.count)
        self.walletService = walletService
        self.onFinish = onFinish
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
    
    func importWallet() throws  {
        let name = WalletNameGenerator(type: .multicoin, walletService: walletService).name
        try walletService.importWallet(name: name, type: .phrase(words: words, chains: AssetConfiguration.allChains))
        onFinish?()
    }
}
