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
        let remoteSubscriptions = try await getSubscriptions(deviceId: deviceId).asSet()
        let localWalletSubscriptions = try localSubscriptions()
        let localSubscriptions = localWalletSubscriptions.map(\.asWalletSubscriptionChains).asSet()

        switch preferences.isSubscriptionsEnabled {
        case true:
            let addSubscribedWallets = localSubscriptions.subtracting(remoteSubscriptions)
            let deleteSubscribedWallets = remoteSubscriptions.subtracting(localSubscriptions)

            let addSubscriptions = localWalletSubscriptions.filter { addSubscribedWallets.contains($0.asWalletSubscriptionChains) }
            let deleteSubscriptions = localWalletSubscriptions.filter { deleteSubscribedWallets.contains($0.asWalletSubscriptionChains) }

            if !addSubscriptions.isEmpty {
                try await updateSubscriptions(deviceId: deviceId, subscriptions: addSubscriptions)
            }
            if !deleteSubscriptions.isEmpty {
                try await self.deleteSubscriptions(deviceId: deviceId, subscriptions: deleteSubscriptions)
            }
        case false:
            if !remoteSubscriptions.isEmpty {
                let deleteSubscriptions = localWalletSubscriptions.filter { remoteSubscriptions.contains($0.asWalletSubscriptionChains) }
                try await self.deleteSubscriptions(deviceId: deviceId, subscriptions: deleteSubscriptions)
            }
        }
        preferences.subscriptionsVersionHasChange = false
    }

    private func localSubscriptions() throws -> [WalletSubscription] {
        try walletStore.getWallets().map { wallet in
            try WalletSubscription(
                wallet_id: wallet.walletIdentifier().id,
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
