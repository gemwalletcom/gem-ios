// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceService
import Preferences
import BalanceService
import AssetsService
import DiscoverAssetsService
import Store
import WalletSessionService
import DeviceService

public struct WalletsService: Sendable {
    private let walletSessionService: any WalletSessionManageable
    private let discoveryProcessor: any DiscoveryAssetsProcessing
    private let assetsEnabler: any AssetsEnabler
    private let priceUpdater: any PriceUpdater
    private let balanceUpdater: any BalanceUpdater
    private let assetsVisibilityManager: any AssetVisibilityServiceable
    
    public init(
        walletStore: WalletStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        priceObserver: PriceObserverService,
        preferences: ObservablePreferences = .default,
        deviceService: any DeviceServiceable
    ) {

        let walletSessionService = WalletSessionService(walletStore: walletStore, preferences: preferences)
        let balanceUpdater = BalanceUpdateService(
            balanceService: balanceService,
            walletSessionService: walletSessionService
        )
        let priceUpdater = PriceUpdateService(priceObserver: priceObserver)

        let assetsEnabler = AssetsEnablerService(
            assetsService: assetsService,
            balanceUpdater: balanceUpdater,
            priceUpdater: priceUpdater
        )
        let processor = DiscoveryAssetsProcessor(
            deviceService: deviceService,
            discoverAssetService: DiscoverAssetsService(balanceService: balanceService),
            priceUpdater: priceUpdater,
            walletSessionService: walletSessionService,
            assetsEnabler: assetsEnabler
        )
        self.assetsVisibilityManager = AssetVisibilityManager(service: balanceService)
        self.assetsEnabler = assetsEnabler
        self.balanceUpdater = balanceUpdater
        self.priceUpdater = priceUpdater
        self.discoveryProcessor = processor
        self.walletSessionService = walletSessionService
    }

    public func walletsCount() throws -> Int {
        try walletSessionService.getWallets().count
    }

    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        async let updateAssets: () = try updateAssets(walletId: walletId, assetIds: assetIds)
        async let assets: () = try await discoveryProcessor.discoverAssets(for: walletId, preferences: WalletPreferences(walletId: walletId.id))

        let _ = try await [updateAssets, assets]
    }

    public func setup(wallet: Wallet) throws {
        try enableBalances(for: wallet.walletId, chains: wallet.chains)
    }
}

// MARK: - DiscoveryAssetsProcessing

extension WalletsService: DiscoveryAssetsProcessing {
    public func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        try await discoveryProcessor.discoverAssets(for: walletId, preferences: preferences)
    }
}

// MARK: - AssetsEnabler

extension WalletsService: AssetsEnabler {
    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async {
        await assetsEnabler.enableAssets(walletId: walletId, assetIds: assetIds, enabled: enabled)
    }
}

// MARK: - PriceUpdater

extension WalletsService: PriceUpdater {
    public func addPrices(assetIds: [AssetId]) async throws {
        try await priceUpdater.addPrices(assetIds: assetIds)
    }
}

// MARK: - BalanceUpdater


extension WalletsService: BalanceUpdater {
    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    public func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws {
        try balanceUpdater.enableBalances(for: walletId, assetIds: assetIds)
    }
}

// MARK: - AssetVisibilityManager

extension WalletsService: AssetVisibilityServiceable {
    public func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.setPinned(isPinned, walletId: walletId, assetId: assetId)
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.hideAsset(walletId: walletId, assetId: assetId)
    }
}
