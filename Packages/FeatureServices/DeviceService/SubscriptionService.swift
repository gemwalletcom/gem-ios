// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import Preferences

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
        let localSubscriptions = try localSubscription().asSet()

        let remoteSubscriptionsV2 = try await getSubscriptionsV2(deviceId: deviceId).asSet()
        let localSubscriptionsV2 = try localSubscriptionV2().asSet()

        switch preferences.isSubscriptionsEnabled {
        case true:
            let addSubscriptions = localSubscriptions.subtracting(remoteSubscriptions).asArray()
            let deleteSubscriptions = remoteSubscriptions.subtracting(localSubscriptions).asArray()

            let addSubscriptionsV2 = localSubscriptionsV2.subtracting(remoteSubscriptionsV2).asArray()
            let deleteSubscriptionsV2 = remoteSubscriptionsV2.subtracting(localSubscriptionsV2).asArray()

            if !addSubscriptions.isEmpty {
                try await updateSubscriptions(deviceId: deviceId, subscriptions: addSubscriptions)
            }
            if !deleteSubscriptions.isEmpty {
                try await self.deleteSubscriptions(deviceId: deviceId, subscriptions: deleteSubscriptions)
            }
            if !addSubscriptionsV2.isEmpty {
                try await updateSubscriptionsV2(deviceId: deviceId, subscriptions: addSubscriptionsV2)
            }
            if !deleteSubscriptionsV2.isEmpty {
                try await self.deleteSubscriptionsV2(deviceId: deviceId, subscriptions: deleteSubscriptionsV2)
            }
        case false:
            if !remoteSubscriptions.isEmpty {
                try await self.deleteSubscriptions(deviceId: deviceId, subscriptions: remoteSubscriptions.asArray())
            }
            if !remoteSubscriptionsV2.isEmpty {
                try await self.deleteSubscriptionsV2(deviceId: deviceId, subscriptions: remoteSubscriptionsV2.asArray())
            }
        }
        preferences.subscriptionsVersionHasChange = false
    }

    private func localSubscription() throws -> [Primitives.Subscription] {
        try walletStore.getWallets().flatMap { wallet in
            wallet.accounts.map {
                Primitives.Subscription(wallet_index: wallet.index, chain: $0.chain, address: $0.address)
            }
        }
    }

    private func localSubscriptionV2() throws -> [WalletSubscription] {
        try walletStore.getWallets().compactMap { wallet in
            wallet.walletIdType.map {
                WalletSubscription(
                    wallet_id: $0,
                    source: wallet.source,
                    subscriptions: wallet.accounts.map { ChainAddress(chain: $0.chain, address: $0.address) }
                )
            }
        }
    }

    private func getSubscriptions(deviceId: String) async throws -> [Primitives.Subscription] {
        try await subscriptionProvider.getSubscriptions(deviceId: deviceId)
    }

    private func getSubscriptionsV2(deviceId: String) async throws -> [WalletSubscription] {
        try await subscriptionProvider.getSubscriptionsV2(deviceId: deviceId)
    }

    private func updateSubscriptions(deviceId: String, subscriptions: [Primitives.Subscription]) async throws {
        try await subscriptionProvider.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }

    private func updateSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await subscriptionProvider.addSubscriptionsV2(deviceId: deviceId, subscriptions: subscriptions)
    }

    private func deleteSubscriptions(deviceId: String, subscriptions: [Primitives.Subscription]) async throws {
        try await subscriptionProvider.deleteSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }

    private func deleteSubscriptionsV2(deviceId: String, subscriptions: [WalletSubscription]) async throws {
        try await subscriptionProvider.deleteSubscriptionsV2(deviceId: deviceId, subscriptions: subscriptions)
    }
}
