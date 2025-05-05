import Foundation
import WalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents

@Observable
final class CreateWalletViewModel: SecretPhraseViewableModel {
    private let walletService: WalletService
    private let router: Routing

    var words: [String] = []

    init(
        walletService: WalletService,
        router: Routing
    ) {
        self.walletService = walletService
        self.router = router
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

    func generateWords() -> [String] {
        walletService.createWallet()
    }
    
    var presentWarning: Bool {
        true
    }

    func continueAction() {
        router.push(to: CreateWalletRoute.verifyPhrase(words))
    }
}
