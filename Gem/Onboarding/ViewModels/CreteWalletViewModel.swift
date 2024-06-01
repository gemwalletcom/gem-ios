import Foundation
import Keystore
import Primitives
import Settings

class CreateWalletViewModel: SecretPhraseViewableModel, ObservableObject {
    
    let keystore: any Keystore

    init(
        keystore: any Keystore
    ) {
        self.keystore = keystore
    }
    
    @Published var words: [String] = []
    
    var title: String {
        return Localized.Wallet.New.title
    }
    
    func generateWords() -> [String] {
        return keystore.createWallet()
    }
    
    var presentWarning: Bool {
        return true
    }
}
