// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences
import Primitives
import Store

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
        try setupEarn()
    }

    public func setupWallet(wallet: Wallet) throws {
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
            NewBanner.tradePerpetuals(assetId: Chain.hyperCore.assetId),
            NewBanner.tradePerpetuals(assetId: Chain.hyperliquid.assetId)
        ])
    }

    private func setupEarn() throws {
        let usdcBase = AssetId(chain: .base, tokenId: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913")
        let usdtEthereum = AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")

        try store.addBanners([
            NewBanner.earn(assetId: usdcBase),
            NewBanner.earn(assetId: usdtEthereum)
        ])
    }
}
