import Foundation
import Keystore
import Primitives
import SwiftUI

struct WalletsViewModel {
    let keystore: any Keystore
    
    init(
        keystore: any Keystore
    ) {
        self.keystore = keystore
    }
    
    var title: String {
        Localized.Wallets.title
    }
    
    var currentWallet: Wallet {
        keystore.currentWallet!
    }
}

// MARK: - Business Logic

extension WalletsViewModel {
    func setCurrent(_ wallet: Wallet) {
        keystore.setCurrentWallet(wallet: wallet)
    }

    func delete(_ wallet: Wallet) throws {
        try keystore.deleteWallet(for: wallet)

        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
    }
}
