// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Preferences

public struct WalletSessionService: WalletSessionManageable {
    private let walletStore: WalletStore
    private let preferences: ObservablePreferences

    public init(
        walletStore: WalletStore,
        preferences: ObservablePreferences
    ) {
        self.walletStore = walletStore
        self.preferences = preferences
    }

    public var currentWallet: Wallet? {
        guard let currentWalletId else { return nil }
        return wallets.first(where: {$0.walletId == currentWalletId })
    }

    public var currentWalletId: Primitives.WalletId? {
        guard let id = preferences.currentWalletId else { return nil }
        return WalletId(id: id)
    }

    public func setCurrent(index: Int) -> WalletId? {
        if let wallet = wallets.first(where: { $0.index == index }) {
            preferences.currentWalletId = wallet.id
            return wallet.walletId
        }
        return nil
    }

    public func setCurrent(walletId: WalletId?) {
        preferences.currentWalletId = walletId?.id
    }

    public func getWallets() throws -> [Wallet] {
        try walletStore.getWallets()
    }
}
