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
        let remoteSubscriptions = try await getSubscriptions(deviceId: deviceId)
        let localWalletSubscriptions = try localSubscriptions()

        let changes = Self.calculateChanges(
            local: localWalletSubscriptions,
            remote: remoteSubscriptions
        )

        if !changes.hasChanges {
            preferences.subscriptionsVersionHasChange = false
            return
        }

        if !changes.toAdd.isEmpty {
            try await updateSubscriptions(deviceId: deviceId, subscriptions: changes.toAdd)
        }

        if !changes.toDelete.isEmpty {
            try await deleteSubscriptions(deviceId: deviceId, subscriptions: changes.toDelete)
        }

        preferences.subscriptionsVersionHasChange = false
    }

    static func calculateChanges(
        local: [WalletSubscription],
        remote: [WalletSubscriptionChains]
    ) -> SubscriptionChanges {
        let localSet = local.map(\.asWalletSubscriptionChains).asSet()
        let remoteSet = remote.asSet()

        let addedWallets = localSet.subtracting(remoteSet)
        let deletedWallets = remoteSet.subtracting(localSet)

        let toAdd = local.filter { addedWallets.contains($0.asWalletSubscriptionChains) }
        let toDelete = local.filter { deletedWallets.contains($0.asWalletSubscriptionChains) }

        return SubscriptionChanges(toAdd: toAdd, toDelete: toDelete)
    }

    private func localSubscriptions() throws -> [WalletSubscription] {
        try walletStore.getWallets().map { wallet in
            WalletSubscription(
                wallet_id: try wallet.walletIdentifier().id,
                source: wallet.source,
                subscriptions: wallet.accounts.map { ChainAddress(chain: $0.chain, address: $0.address) }
            )
        }
    }

    private func getSubscriptions(deviceId: String) async throws -> [WalletSubscriptionChains] {
        try await subscriptionProvider.getSubscriptions(deviceId: deviceId)
    }

    private func updateSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await subscriptionProvider.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }

    private func deleteSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await subscriptionProvider.deleteSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }
}
