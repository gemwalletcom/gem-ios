import Foundation
import Primitives
import SwiftUI
import Localization
import Preferences
import WalletService
import Components

@Observable
@MainActor
public final class WalletsSceneViewModel {
    private let walletService: WalletService
    let currentWalletId: WalletId?
    
    public var service: WalletService {
        walletService
    }
    
    var isPresentingAlertMessage: AlertMessage?
    var walletDelete: Wallet?
    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false
    public var walletToEdit: Wallet?
    public var isPresentingWallets: Bool = false
    
    public init(walletService: WalletService) {
        self.walletService = walletService
        self.currentWalletId = walletService.currentWalletId
        self.isPresentingAlertMessage = nil
        self.walletDelete = nil
        self.walletToEdit = nil
        self.isPresentingWallets = false
    }
    
    var title: String {
        Localized.Wallets.title
    }
}

// MARK: - Business Logic

extension WalletsSceneViewModel {
    func setCurrent(_ walletId: WalletId) {
        walletService.setCurrent(for: walletId)
    }

    func onEdit(wallet: Wallet) {
        walletToEdit = wallet
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

// MARK: - Actions

extension WalletsSceneViewModel {
    func onDelete(wallet: Wallet) {
        walletDelete = wallet
    }
    
    func onPin(wallet: Wallet) {
        do {
            try pin(wallet)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
    
    func onDeleteConfirmed(wallet: Wallet) {
        do {
            try delete(wallet)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
    
    public func onCreateWallet() {
        isPresentingCreateWalletSheet = true
    }
    
    public func onImportWallet() {
        isPresentingImportWalletSheet = true
    }
    
    public func onDismiss() {
        isPresentingWallets = false
    }
}
