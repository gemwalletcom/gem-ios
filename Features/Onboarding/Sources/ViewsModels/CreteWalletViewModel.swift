import Foundation
import Keystore
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents

class CreateWalletViewModel: SecretPhraseViewableModel, ObservableObject {
    private let keystore: any Keystore
    private let onCreateWallet: (([String]) -> Void)?

    @Published var words: [String] = []

    init(
        keystore: any Keystore,
        onCreateWallet: (([String]) -> Void)? = nil
    ) {
        self.keystore = keystore
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

    func generateWords() -> [String] {
        keystore.createWallet()
    }
    
    var presentWarning: Bool {
        true
    }

    func continueAction() {
        onCreateWallet?(words)
    }
}
