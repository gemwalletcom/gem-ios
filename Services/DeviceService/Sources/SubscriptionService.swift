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
        
        switch preferences.isSubscriptionsEnabled {
        case true:
            let addSubscriptions = localSubscriptions.subtracting(remoteSubscriptions).asArray()
            let deleteSubcriptions = remoteSubscriptions.subtracting(localSubscriptions).asArray()
            
            if !addSubscriptions.isEmpty {
                try await updateSubscriptions(deviceId: deviceId, subscriptions: addSubscriptions)
            }
            if !deleteSubcriptions.isEmpty {
                try await deleteSubscriptions(deviceId: deviceId, subscriptions: deleteSubcriptions)
            }
        case false:
            if !remoteSubscriptions.isEmpty {
                try await deleteSubscriptions(deviceId: deviceId, subscriptions: remoteSubscriptions.asArray())
            }
        }
        preferences.subscriptionsVersionHasChange = false
    }
    
    private func localSubscription() throws -> [Primitives.Subscription] {
        return try walletStore.getWallets().map { wallet in
            wallet.accounts.map {
                Primitives.Subscription(wallet_index: wallet.index, chain: $0.chain, address: $0.address)
            }
        }.flatMap { $0 }
    }
    
    private  func getSubscriptions(deviceId: String) async throws -> [Primitives.Subscription] {
        return try await subscriptionProvider.getSubscriptions(deviceId: deviceId)
    }
    
    private func updateSubscriptions(deviceId: String, subscriptions: [Primitives.Subscription]) async throws {
        return try await subscriptionProvider
            .addSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }
    
    private func deleteSubscriptions(deviceId: String, subscriptions: [Primitives.Subscription]) async throws {
        return try await subscriptionProvider
            .deleteSubscriptions(deviceId: deviceId, subscriptions: subscriptions)
    }
}
