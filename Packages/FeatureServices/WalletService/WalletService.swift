// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Preferences
import Keystore
import AvatarService
import WalletSessionService

public struct WalletService: Sendable {
    private let keystore: any Keystore
    private let walletStore: WalletStore
    private let avatarService: AvatarService
    private let walletSessionService: any WalletSessionManageable
    private let preferences: ObservablePreferences

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
        self.preferences = preferences
    }

    public var currentWalletId: WalletId? {
        walletSessionService.currentWalletId
    }
    
    public var currentWallet: Wallet? {
        walletSessionService.currentWallet
    }

    public var wallets: [Wallet] {
        walletSessionService.wallets
    }
    
    public var isAcceptTermsCompleted: Bool {
        preferences.isAcceptTermsCompleted
    }
    
    public func nextWalletIndex() throws -> Int {
        try walletStore.nextWalletIndex()
    }

    public func setCurrent(for index: Int) {
        walletSessionService.setCurrent(index: index)
    }

    public func setCurrent(for walletId: WalletId) {
        walletSessionService.setCurrent(walletId: walletId)
    }
    
    public func acceptTerms() {
        preferences.isAcceptTermsCompleted = true
    }

    public func createWallet() -> [String] {
        keystore.createWallet()
    }

    @discardableResult
    public func importWallet(name: String, type: KeystoreImportType) throws -> Wallet {
        let newWallet = try keystore.importWallet(
            name: name,
            type: type,
            isWalletsEmpty: wallets.isEmpty
        )
        try walletStore.addWallet(newWallet)
        walletSessionService.setCurrent(walletId: newWallet.walletId)
        return newWallet
    }

    public func delete(_ wallet: Wallet) throws {
        try avatarService.remove(for: wallet.id)
        try keystore.deleteKey(for: wallet)
        try walletStore.deleteWallet(for: wallet.id)


        if currentWalletId == wallet.walletId {
            walletSessionService.setCurrent(walletId: wallets.first?.walletId)
        }

        // TODO: - enable once will be enabled in CleanUpService
        /*
        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
         */
    }

    public func setup(chains: [Chain]) throws {
        let wallets = walletSessionService.wallets.filter { $0.type == .multicoin }
        guard !wallets.isEmpty else { return }

        let setupWallets = try keystore.setupChains(chains: chains, for: wallets)
        for wallet in setupWallets {
            try walletStore.addWallet(wallet)
        }
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
    
    public func rename(walletId: WalletId, newName: String) throws {
        try walletStore.renameWallet(walletId.id, name: newName)
    }
    
    public func getMnemonic(wallet: Wallet) throws -> [String] {
        try keystore.getMnemonic(wallet: wallet)
    }
    
    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String {
        try keystore.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }
}
