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

    var continueAction: VoidAction {
        { onCreateWallet(words) }
    }

    init(
        walletService: WalletService,
        onCreateWallet: @escaping (([String]) -> Void)
    ) {
        self.walletService = walletService
        self.onCreateWallet = onCreateWallet
        do {
            self.words = try walletService.createWallet()
        } catch {
            fatalError("Unable to create wallet")
        }
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
}
