import Foundation
import Primitives
import SwiftUI
import Localization
import Keystore
import Preferences
import ManageWalletService

public class WalletsSceneViewModel {
    @Binding var navigationPath: NavigationPath
    let manageWalletService: ManageWalletService

    public init(
        navigationPath: Binding<NavigationPath>,
        manageWalletService: ManageWalletService
    ) {
        _navigationPath = navigationPath
        self.manageWalletService = manageWalletService
    }
    
    var title: String {
        Localized.Wallets.title
    }
    
    var currentWallet: Wallet? {
        manageWalletService.currentWallet
    }
}

// MARK: - Business Logic

extension WalletsSceneViewModel {
    func setCurrent(_ walletId: WalletId) {
        manageWalletService.setCurrent(walletId)
    }

    func onEdit(wallet: Wallet) {
        navigationPath.append(Scenes.WalletDetail(wallet: wallet))
    }

    func delete(_ wallet: Wallet) throws {
        try manageWalletService.delete(wallet)
    }

    func pin(_ wallet: Wallet) throws {
        if wallet.isPinned {
            try manageWalletService.unpin(wallet: wallet)
        } else {
            try manageWalletService.pin(wallet: wallet)
        }
    }

    func swapOrder(from: WalletId, to: WalletId) throws {
        try manageWalletService.swapOrder(from: from, to: to)
    }
}
