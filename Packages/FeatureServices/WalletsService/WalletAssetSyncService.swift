// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import DiscoverAssetsService
import Primitives
import Preferences
import WalletSessionService
import DeviceService

public actor WalletAssetSyncService: AssetSyncServiceable, DiscoveryAssetsProcessing {
    private let deviceService: any DeviceServiceable
    private let discoverAssetService: DiscoverAssetsService
    private let assetService: AssetsService
    private let priceUpdater: any PriceUpdater
    private let balanceUpdater: any BalanceUpdater
    private let assetsEnabler: any AssetsEnabler
    private let walletSessionService: any WalletSessionManageable

    public init(
        deviceService: any DeviceServiceable,
        discoverAssetService: DiscoverAssetsService,
        assetService: AssetsService,
        priceUpdater: any PriceUpdater,
        balanceUpdater: any BalanceUpdater,
        assetsEnabler: any AssetsEnabler,
        walletSessionService: any WalletSessionManageable
    ) {
        self.deviceService = deviceService
        self.discoverAssetService = discoverAssetService
        self.assetService = assetService
        self.priceUpdater = priceUpdater
        self.balanceUpdater = balanceUpdater
        self.assetsEnabler = assetsEnabler
        self.walletSessionService = walletSessionService
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        async let updateAssets: () = try updateAssets(walletId: walletId, assetIds: assetIds)
        async let discoverAssets: () = try discoverAssets(
            for: walletId,
            preferences: WalletPreferences(walletId: walletId)
        )
        _ = try await (updateAssets, discoverAssets)
    }

    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    public func addPrices(assetIds: [AssetId]) async throws {
        try await priceUpdater.addPrices(assetIds: assetIds)
    }

    func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        _ = try await deviceService.getSubscriptionsDeviceId()

        let assetIds = try await discoverAssetService.getAssets(
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )

        if assetIds.isNotEmpty {
            try await assetService.prefetchAssets(assetIds: assetIds)
            try await assetsEnabler.enableAssets(
                walletId: wallet.walletId,
                assetIds: assetIds,
                enabled: true
            )
        }

        preferences.completeInitialLoadAssets = true
        preferences.assetsTimestamp = Int(Date.now.timeIntervalSince1970)
    }
}
