// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct BannerSetupService: Sendable {

    private let store: BannerStore
    private let preferences: Preferences

    public init(
        store: BannerStore,
        preferences: Preferences
    ) {
        self.store = store
        self.preferences = preferences
    }

    public func setup() throws {
        let stakeChains = StakeChain.allCases.filter({ $0 != .ethereum })
        for chain in stakeChains {
            try store.addBanner(
                NewBanner(walletId: .none, assetId: chain.chain.assetId, event: .stake, state: .active)
            )
        }

        // Enable push notifications
        if !preferences.isPushNotificationsEnabled && preferences.launchesCount > 2 {
            try store.addBanner(
                NewBanner(walletId: .none, assetId: .none, event: .enableNotifications, state: .active)
            )
        }
    }

    public func setupWallet(wallet: Wallet) throws  {
        // Adding XRP activation fee banner
        try store.addBanner(
            NewBanner(walletId: .none, assetId: .none, event: .accountActivation, state: .active)
        )
    }
}
