// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletService
import SwiftUI
import Style
import Localization
import PrimitivesComponents
import Preferences
import Components

@Observable
@MainActor
final class VerifyPhraseViewModel {
    
    private let words: [String]
    private let shuffledWords: [String]
    private let walletService: WalletService
    private let onFinish: VoidAction

    var wordsVerified: [String]
    var wordsIndex: Int = 0
    var buttonState = ButtonState.disabled
    var isPresentingAlertMessage: AlertMessage?
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
        self.isPresentingAlertMessage = nil
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
    
    func importWallet() async throws  {
        let name = WalletNameGenerator(type: .multicoin, walletService: walletService).name
        let wallet = try await walletService.importWallet(name: name, type: .phrase(words: self.words, chains: AssetConfiguration.allChains))

        WalletPreferences(walletId: wallet.id).completeInitialSynchronization()
        walletService.acceptTerms()

        onFinish?()
    }
}

// MARK: - Actions

extension VerifyPhraseViewModel {
    func onImportWallet() {
        buttonState = .loading(showProgress: true)
        Task {
            do {
                try await importWallet()
            } catch {
                isPresentingAlertMessage = AlertMessage(
                    title: Localized.Errors.createWallet(""),
                    message: error.localizedDescription
                )
                buttonState = .normal
            }
        }
    }
}
