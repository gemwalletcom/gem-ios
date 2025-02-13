// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Keystore
import Preferences
import AvatarService

public struct WalletService {

    private let keystore: any Keystore
    private let walletStore: WalletStore
    private let preferences: Preferences
    private let avatarService: AvatarService

    var currentWallet: Wallet? {
        keystore.currentWallet
    }

    init(
        keystore: any Keystore,
        walletStore: WalletStore,
        preferences: Preferences = .standard,
        avatarService: AvatarService
    ) {
        self.keystore = keystore
        self.walletStore = walletStore
        self.preferences = preferences
        self.avatarService = avatarService
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
        try? avatarService.remove(for: wallet.id)
        try keystore.deleteWallet(for: wallet)

        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore, preferences: preferences).onDeleteAllWallets()
        }
    }

    func swapOrder(from: WalletId, to: WalletId) throws {
        try walletStore.swapOrder(from: from, to: to)
    }
    
    func renameWallet(wallet: Wallet, newName: String) throws {
        try keystore.renameWallet(wallet: wallet, newName: newName)
    }
    
    func getMnemonic(wallet: Wallet) throws -> [String] {
        try keystore.getMnemonic(wallet: wallet)
    }
    
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String {
        try keystore.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }
}
