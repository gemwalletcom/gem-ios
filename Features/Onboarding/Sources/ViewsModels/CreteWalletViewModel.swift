import Foundation
import ManageWalletService
import Primitives
import SwiftUI
import Localization
import PrimitivesComponents

class CreateWalletViewModel: SecretPhraseViewableModel, ObservableObject {
    private let manageWalletService: ManageWalletService
    private let onCreateWallet: (([String]) -> Void)?

    @Published var words: [String] = []

    init(
        manageWalletService: ManageWalletService,
        onCreateWallet: (([String]) -> Void)? = nil
    ) {
        self.manageWalletService = manageWalletService
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
        manageWalletService.createWallet()
    }
    
    var presentWarning: Bool {
        true
    }

    func continueAction() {
        onCreateWallet?(words)
    }
}
