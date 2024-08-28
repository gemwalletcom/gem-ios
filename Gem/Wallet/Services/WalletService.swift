// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Keystore

public struct WalletService {

    private let keystore: any Keystore
    private let walletStore: WalletStore

    var currentWallet: Wallet? {
        keystore.currentWallet
    }

    init(
        keystore: any Keystore,
        walletStore: WalletStore
    ) {
        self.keystore = keystore
        self.walletStore = walletStore
    }

    func pin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: true)
    }

    func unpin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: false)
    }

    func setCurrent(_ walletId: WalletId) {
        keystore.setCurrentWalletId(walletId)
    }

    func delete(_ wallet: Wallet) throws {
        try keystore.deleteWallet(for: wallet)

        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
    }

    func swapOrder(from: WalletId, to: WalletId) throws {
        try walletStore.swapOrder(from: from, to: to)
    }
}
