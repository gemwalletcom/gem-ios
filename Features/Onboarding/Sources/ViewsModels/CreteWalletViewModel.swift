import Foundation
import WalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents

@MainActor
protocol CreateWalletViewModelNavigation {
    func createWalletOnNext(words: [String])
}

@Observable
final class CreateWalletViewModel: SecretPhraseViewableModel {
    private let walletService: WalletService
    private let navigation: CreateWalletViewModelNavigation

    var words: [String] = []

    init(
        walletService: WalletService,
        navigation: CreateWalletViewModelNavigation
    ) {
        self.walletService = walletService
        self.navigation = navigation
    }

    var title: String {
        Localized.Wallet.New.title
    }

    var type: SecretPhraseDataType {
        .words(words: WordIndex.rows(for: words))
    }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .secretPhrase,
            copyValue: MnemonicFormatter.fromArray(words: words)
        )
    }
    
    var presentWarning: Bool {
        true
    }

    func generateWords() -> [String] {
        walletService.createWallet()
    }
    
}

// MARK: - Navigation

@MainActor
extension CreateWalletViewModel {
    func onNext() {
        navigation.createWalletOnNext(words: words)
    }
}
