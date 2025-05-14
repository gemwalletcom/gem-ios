import Foundation
import Primitives
import SwiftUI
import Localization
import Preferences
import WalletService

public class WalletsSceneViewModel {
    @Binding var navigationPath: NavigationPath
    let service: WalletService
    let currentWalletId: WalletId?
    
    public init(
        navigationPath: Binding<NavigationPath>,
        walletService: WalletService
    ) {
        _navigationPath = navigationPath
        self.service = walletService
        self.currentWalletId = service.currentWaletId
    }
    
    var title: String {
        Localized.Wallets.title
    }
}

// MARK: - Business Logic

extension WalletsSceneViewModel {
    func setCurrent(_ walletId: WalletId) {
        service.setCurrent(for: walletId)
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
