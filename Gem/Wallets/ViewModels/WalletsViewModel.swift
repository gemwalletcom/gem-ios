import Foundation
import Keystore
import Primitives
import SwiftUI

class WalletsViewModel {

    @Binding var navigationPath: NavigationPath
    let walletService: WalletService

    init(
        navigationPath: Binding<NavigationPath>,
        walletService: WalletService
    ) {
        _navigationPath = navigationPath
        self.walletService = walletService
    }
    
    var title: String {
        Localized.Wallets.title
    }
    
    var currentWallet: Wallet? {
        walletService.currentWallet
    }
}

// MARK: - Business Logic

extension WalletsViewModel {
    func setCurrent(_ walletId: WalletId) {
        walletService.setCurrent(walletId)
    }

    func onEdit(wallet: Wallet) {
        navigationPath.append(Scenes.WalletDetail(wallet: wallet))
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

    func swapOrder(from: WalletId, to: WalletId) throws {
        try walletService.swapOrder(from: from, to: to)
    }
}
