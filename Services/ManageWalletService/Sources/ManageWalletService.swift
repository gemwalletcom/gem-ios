// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
@preconcurrency import Keystore
import AvatarService

public struct ManageWalletService: Sendable {
    private let keystore: any Keystore
    private let walletStore: WalletStore
    private let preferences: Preferences
    private let avatarService: AvatarService

    public var currentWallet: Wallet? {
        keystore.currentWallet
    }

    public init(
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

    public func pin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: true)
    }

    public func unpin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: false)
    }

    public func setCurrent(_ walletId: WalletId) {
        keystore.setCurrentWalletId(walletId)
    }

    func delete(_ wallet: Wallet) throws {
        try? avatarService.remove(for: wallet.id)
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
