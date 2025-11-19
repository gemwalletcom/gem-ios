// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Preferences

public struct BannerSetupService: Sendable {

    private let store: BannerStore
    private let preferences: Preferences

    public init(
        store: BannerStore,
        preferences: Preferences = .standard
    ) {
        self.store = store
        self.preferences = preferences
    }
    
    public func setup() throws {
        try setupStake()
        try setupHypercorePerpetuals()

        // Enable push notifications
        if !preferences.isPushNotificationsEnabled && preferences.launchesCount > 2 {
            try store.addBanners([
                NewBanner(event: .enableNotifications, state: .active)
            ])
        }
    }

    public func setupWallet(wallet: Wallet) throws  {
        try setupAccountActivation()
        try setupOnboarding(wallet: wallet)
    }
    
    public func setupAccountMultiSignatureWallet(walletId: WalletId, chain: Chain) throws {
        try store.addBanners([
            NewBanner.accountBlockedMultiSignature(walletId: walletId, chain: chain)
        ])
    }
    
    // MARK: - Private methods
    
    private func setupStake() throws {
        try store.addBanners(StakeChain.allCases.map {
            NewBanner.stake(assetId: $0.chain.assetId)
        })
    }

    private func setupAccountActivation() throws {
        let chains: [Chain] = [.xrp, .stellar, .algorand]
        let banners = chains.map {
            NewBanner.accountActivation(assetId: $0.assetId)
        }
        try store.addBanners(banners)
    }

    private func setupOnboarding(wallet: Wallet) throws {
        switch wallet.source {
        case .create: try store.addBanners([NewBanner.onboarding(walletId: wallet.walletId)])
        case .import: break
        }
    }

    private func setupHypercorePerpetuals() throws {
        try store.addBanners([
            NewBanner.tradePerpetuals(assetId: Chain.hyperCore.assetId)
        ])
    }
}
