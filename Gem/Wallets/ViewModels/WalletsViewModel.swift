import Foundation
import Keystore
import Primitives
import SwiftUI

struct WalletsViewModel {

    let walletService: WalletService

    init(
        walletService: WalletService
    ) {
        self.walletService = walletService
    }
    
    var title: String {
        Localized.Wallets.title
    }
    
    var currentWallet: Wallet {
        walletService.currentWallet!
    }
}

// MARK: - Business Logic

extension WalletsViewModel {
    func setCurrent(_ walletId: WalletId) {
        walletService.setCurrent(walletId)
    }

    func delete(_ wallet: Wallet) throws {
        try walletService.delete(wallet)
    }

    func pin(_ wallet: Wallet) throws {
        if wallet.isPinned {
            try walletService.unpin(wallet: wallet)
        } else {
            try walletService.pin(wallet: wallet)
        }
    }
}
