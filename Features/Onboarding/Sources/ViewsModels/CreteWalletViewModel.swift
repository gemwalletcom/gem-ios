import Foundation
import WalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents
import Formatters

class CreateWalletViewModel: SecretPhraseViewableModel, ObservableObject {
    private let walletService: WalletService
    private let onCreateWallet: (([String]) -> Void)?

    @Published var words: [String] = []

    init(
        walletService: WalletService,
        onCreateWallet: (([String]) -> Void)? = nil
    ) {
        self.walletService = walletService
        self.onCreateWallet = onCreateWallet
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
    
    // TODO: - Replace from Gemstone Docs
    var docsUrl: URL {
        URL(string: "https://docs.gemwallet.com/faq/secure-recovery-phrase/#how-to-secure-my-secret-phrase")!
    }

    func generateWords() {
        words = walletService.createWallet()
    }
    
    var presentWarning: Bool {
        true
    }

    func continueAction() {
        onCreateWallet?(words)
    }
}
