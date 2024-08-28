import Foundation
import Keystore
import Primitives
import Settings
import SwiftUI

class CreateWalletViewModel: SecretPhraseViewableModel, ObservableObject {
    
    @Binding private var navigationPath: NavigationPath

    let keystore: any Keystore

    init(
        navigationPath: Binding<NavigationPath>,
        keystore: any Keystore
    ) {
        _navigationPath = navigationPath
        self.keystore = keystore
    }
    
    @Published var words: [String] = []
    
    var title: String {
        return Localized.Wallet.New.title
    }

    var type: SecretPhraseDataType {
        .words(words: WordIndex.rows(for: words))
    }

    var copyValue: String {
        MnemonicFormatter.fromArray(words: words)
    }

    var copyType: CopyType {
        .secretPhrase
    }

    func generateWords() -> [String] {
        return keystore.createWallet()
    }
    
    var presentWarning: Bool {
        return true
    }

    func continueAction() {
        navigationPath.append(Scenes.VerifyPhrase(words: words))
    }
}
