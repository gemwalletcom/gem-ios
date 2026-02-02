// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Preferences
import Primitives
import Store

public struct SubscriptionService: Sendable {
    private let subscriptionProvider: any GemAPISubscriptionService
    private let preferences: Preferences
    private let walletStore: WalletStore

    public init(
        subscriptionProvider: any GemAPISubscriptionService,
        walletStore: WalletStore,
        preferences: Preferences = .standard
    ) {
        self.subscriptionProvider = subscriptionProvider
        self.walletStore = walletStore
        self.preferences = preferences
    }

    var subscriptionsVersion: Int {
        preferences.subscriptionsVersion
    }

    public func incrementSubscriptionsVersion() {
        preferences.incrementSubscriptionVersion()
    }

    public func update(deviceId: String) async throws {
        let local = try walletStore.getWallets().map { wallet in
            WalletSubscription(
                wallet_id: wallet.id,
                source: wallet.source,
                subscriptions: wallet.accounts.map { ChainAddress(chain: $0.chain, address: $0.address) }
            )
        }
        let remote = try await subscriptionProvider.getSubscriptions(deviceId: deviceId)
        let changes = Self.calculateChanges(local: local, remote: remote)

        guard changes.hasChanges else {
            preferences.subscriptionsVersionHasChange = false
            return
        }

        if !changes.toAdd.isEmpty {
            try await subscriptionProvider.addSubscriptions(deviceId: deviceId, subscriptions: changes.toAdd)
        }

        if !changes.toDelete.isEmpty {
            try await subscriptionProvider.deleteSubscriptions(deviceId: deviceId, subscriptions: changes.toDelete)
        }

        preferences.subscriptionsVersionHasChange = false
    }

    static func calculateChanges(
        local: [WalletSubscription],
        remote: [WalletSubscriptionChains]
    ) -> SubscriptionChanges {
        let remoteByWallet = Dictionary(uniqueKeysWithValues: remote.map { ($0.wallet_id, $0) })
        let localByWallet = Dictionary(uniqueKeysWithValues: local.map { ($0.wallet_id, $0) })

        let toAdd = local.compactMap { wallet -> WalletSubscription? in
            let remoteChains = Set(remoteByWallet[wallet.wallet_id]?.chains ?? [])
            let newChains = wallet.subscriptions.filter { !remoteChains.contains($0.chain) }
            guard !newChains.isEmpty else { return nil }
            return WalletSubscription(wallet_id: wallet.wallet_id, source: wallet.source, subscriptions: newChains)
        }

        let toDelete = remote.compactMap { remoteWallet -> WalletSubscriptionChains? in
            guard let localWallet = localByWallet[remoteWallet.wallet_id] else {
                return remoteWallet
            }
            let localChains = Set(localWallet.subscriptions.map(\.chain))
            let chainsToDelete = remoteWallet.chains.filter { !localChains.contains($0) }
            guard !chainsToDelete.isEmpty else { return nil }
            return WalletSubscriptionChains(wallet_id: remoteWallet.wallet_id, chains: chainsToDelete.sorted())
        }

        return SubscriptionChanges(toAdd: toAdd, toDelete: toDelete)
    }
}
