// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletService
import SwiftUI
import Style
import Localization
import PrimitivesComponents
import Components
import GemstonePrimitives

@Observable
@MainActor
final class VerifyPhraseViewModel {

    private let words: [String]
    private let shuffledWords: [String]
    private let onComplete: ([String]) -> Void

    var wordsVerified: [String]
    var wordsIndex: Int = 0
    var buttonState = ButtonState.disabled
    var isPresentingAlertMessage: AlertMessage?
    private var selectedIndexes = Set<WordIndex>()

    init(
        words: [String],
        onComplete: @escaping ([String]) -> Void
    ) {
        self.words = words
        self.shuffledWords = words.shuffleInGroups(groupSize: 4)
        self.wordsVerified = Array(repeating: "", count: words.count)
        self.onComplete = onComplete
    }
    
    var title: String {
        Localized.VerifyPhrase.title
    }

    var docsUrl: URL {
        Docs.url(.howToSecureSecretPhrase)
    }

    var rows: [[WordIndex]] {
        wordsVerified
            .enumerated()
            .map {
                WordIndex(index: $0.offset, word: $0.element)
            }
            .splitInSubArrays(into: wordsVerified.count / 2)
    }
    
    var rowsSections: [[WordIndex]] {
        selectRows.chunks(4)
    }
    
    var selectRows: [WordIndex] {
        shuffledWords
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
}

// MARK: - Actions

extension VerifyPhraseViewModel {
    func onContinue() {
        buttonState = .loading(showProgress: true)
        onComplete(words)
    }
}
