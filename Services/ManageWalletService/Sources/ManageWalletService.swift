// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
import Keystore
import AvatarService
import WalletSessionService

public struct ManageWalletService: Sendable {
    private let keystore: any Keystore
    private let walletStore: WalletStore
    private let avatarService: AvatarService
    private let walletSessionService: any WalletSessionManageable

    public init(
        keystore: any Keystore,
        walletStore: WalletStore,
        preferences: ObservablePreferences,
        avatarService: AvatarService
    ) {
        self.keystore = keystore
        self.walletStore = walletStore
        self.avatarService = avatarService
        self.walletSessionService = WalletSessionService(walletStore: walletStore, preferences: preferences)
    }

    public var currentWallet: Wallet? {
        walletSessionService.currentWallet
    }

    public var wallets: [Wallet] {
        walletSessionService.wallets
    }

    public func setCurrent(_ index: Int) {
        walletSessionService.setCurrent(index: index)
    }

    public func setCurrent(_ walletId: WalletId) {
        walletSessionService.setCurrent(walletId: walletId)
    }

    public func delete(_ wallet: Wallet) throws {
        try? avatarService.remove(for: wallet.id)
        try keystore.deleteWallet(for: wallet)

        // TODO: - enable once will be enabled in CleanUpService
        /*
        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
         */
    }

    public func pin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: true)
    }

    public func unpin(wallet: Wallet) throws {
        try walletStore.pinWallet(wallet.id, value: false)
    }

    public func swapOrder(from: WalletId, to: WalletId) throws {
        try walletStore.swapOrder(from: from, to: to)
    }
    
    public func renameWallet(wallet: Wallet, newName: String) throws {
        try walletStore.renameWallet(wallet.id, name: newName)
    }
    
    public func getMnemonic(wallet: Wallet) throws -> [String] {
        try keystore.getMnemonic(wallet: wallet)
    }
    
    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String {
        try keystore.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }
}
