// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
@preconcurrency import Keystore

public struct ManageWalletService: Sendable {
    private let keystore: any Keystore
    private let walletStore: WalletStore
    private let preferences: Preferences

    public var currentWallet: Wallet? {
        keystore.currentWallet
    }

    public init(
        keystore: any Keystore,
        walletStore: WalletStore,
        preferences: Preferences = .standard
    ) {
        self.keystore = keystore
        self.walletStore = walletStore
        self.preferences = preferences
    }

    public func pin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: true)
    }

    public func unpin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: false)
    }

    public func setCurrent(_ walletId: WalletId) {
        keystore.setCurrentWalletId(walletId)
    }

    public func delete(_ wallet: Wallet) throws {
        try keystore.deleteWallet(for: wallet)

        // TODO: - enable once will be enabled in CleanUpService
        /*
        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
         */
    }

    public func swapOrder(from: WalletId, to: WalletId) throws {
        try walletStore.swapOrder(from: from, to: to)
    }
}
