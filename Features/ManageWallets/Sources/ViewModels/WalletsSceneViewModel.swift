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
    let service: WalletService
    let currentWalletId: WalletId?
    
    var isPresentingAlertMessage: AlertMessage?
    var walletDelete: Wallet?
    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false
    public var walletToEdit: Wallet?
    
    public init(walletService: WalletService) {
        self.service = walletService
        self.currentWalletId = service.currentWalletId
        self.isPresentingAlertMessage = nil
        self.walletDelete = nil
        self.walletToEdit = nil
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
        walletToEdit = wallet
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
}
