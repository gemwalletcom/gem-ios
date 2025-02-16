import Foundation
import Primitives
import SwiftUI
import Localization
import Preferences
import ManageWalletService

public class WalletsSceneViewModel {
    @Binding var navigationPath: NavigationPath
    let service: ManageWalletService

    public init(
        navigationPath: Binding<NavigationPath>,
        manageWalletService: ManageWalletService
    ) {
        _navigationPath = navigationPath
        self.service = manageWalletService
    }
    
    var title: String {
        Localized.Wallets.title
    }
    
    var currentWallet: Wallet? {
        service.currentWallet
    }
}

// MARK: - Business Logic

extension WalletsSceneViewModel {
    func setCurrent(_ walletId: WalletId) {
        service.setCurrent(walletId)
    }

    func onEdit(wallet: Wallet) {
        navigationPath.append(Scenes.WalletDetail(wallet: wallet))
    }

    func delete(_ wallet: Wallet) throws {
        try service.delete(wallet)
    }

    func pin(_ wallet: Wallet) throws {
        if wallet.isPinned {
            try service.unpin(wallet: wallet)
        } else {
            try service.pin(wallet: wallet)
        }
    }

    func swapOrder(from: WalletId, to: WalletId) throws {
        try service.swapOrder(from: from, to: to)
    }
}
