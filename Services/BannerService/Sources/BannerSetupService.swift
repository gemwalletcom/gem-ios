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
        let stakeChains = StakeChain.allCases.filter { $0 != .ethereum }

        try store.addBanners(stakeChains.map {
            NewBanner.stake(assetId: $0.chain.assetId)
        })

        // Enable push notifications
        if !preferences.isPushNotificationsEnabled && preferences.launchesCount > 2 {
            try store.addBanners([
                NewBanner(event: .enableNotifications, state: .active)
            ])
        }
    }

    public func setupWallet(wallet: Wallet) throws  {
        let chains: [Chain] = [.xrp, .stellar]
        let banners = chains.map {
            NewBanner.accountActivation(assetId: $0.assetId)
        }
        try store.addBanners(banners)
    }
    
    public func setupAccountMultiSignatureWallet(walletId: WalletId, chain: Chain) throws {
        try store.addBanners([
            NewBanner.accountBlockedMultiSignature(walletId: walletId, chain: chain)
        ])
    }
}
