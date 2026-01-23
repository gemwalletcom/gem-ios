import Foundation
import WalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents
import Formatters
import Components
import Style

struct NewSecretPhraseViewModel: SecretPhraseViewableModel {

    private let onCreateWallet: ((SecretData) -> Void)
    let secretData: SecretData

    var calloutViewStyle: CalloutViewStyle? {
        .header(title: Localized.SecretPhrase.savePhraseSafely)
    }

    var continueAction: VoidAction {
        { onCreateWallet(secretData) }
    }

    init(
        walletService: WalletService,
        onCreateWallet: @escaping ((SecretData) -> Void)
    ) {
        self.onCreateWallet = onCreateWallet
        do {
            self.secretData = try walletService.createWallet()
        } catch {
            fatalError("Unable to create wallet")
        }
    }

    var title: String { Localized.Wallet.New.title }
    var type: SecretPhraseDataType { .words(words: WordIndex.rows(for: secretData.words)) }

    var copyModel: CopyTypeViewModel {
        CopyTypeViewModel(
            type: .secretPhrase,
            copyValue: secretData.string
        )
    }
}
