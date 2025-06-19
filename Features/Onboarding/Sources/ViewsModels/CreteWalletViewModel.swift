import Foundation
import WalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents
import Formatters
import Components
import Style

struct CreateWalletViewModel: SecretPhraseViewableModel {
    
    private let walletService: WalletService
    private let onCreateWallet: (([String]) -> Void)
    let words: [String]
    
    var calloutViewStyle: CalloutViewStyle? {
        .header(title: Localized.SecretPhrase.savePhraseSafely)
    }

    var continueAction: Primitives.VoidAction {
        { onCreateWallet(words) }
    }

    init(
        walletService: WalletService,
        onCreateWallet: @escaping (([String]) -> Void)
    ) {
        self.walletService = walletService
        self.onCreateWallet = onCreateWallet
        self.words = walletService.createWallet()
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

    var docsUrl: URL {
        Docs.url(.howToSecureSecretPhrase)
    }
}
