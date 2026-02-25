// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import DiscoverAssetsService
import Primitives
import Preferences
import WalletSessionService
import DeviceService

actor WalletAssetSyncService {
    private let deviceService: any DeviceServiceable
    private let discoverAssetService: DiscoverAssetsService
    private let assetService: AssetsService
    private let priceUpdater: any PriceUpdater
    private let balanceUpdater: any BalanceUpdater
    private let assetsEnabler: any AssetsEnabler
    private let walletSessionService: any WalletSessionManageable

    init(
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

    func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        let preferences = WalletPreferences(walletId: walletId)

        async let updateAssetsTask: () = try updateAssets(walletId: walletId, assetIds: assetIds)
        async let deviceAssetsTask: [AssetId] = try getDeviceAssets(walletId: walletId, preferences: preferences)
        let (_, deviceAssets) = try await (updateAssetsTask, deviceAssetsTask)

        let additionalAssetIds = deviceAssets.asSet().subtracting(assetIds).asArray()
        if additionalAssetIds.isNotEmpty {
            try await enableAssets(walletId: walletId, assetIds: additionalAssetIds)
        }
        setCompleteInitialLoadAssets(preferences: preferences)
    }

    func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    func addPrices(assetIds: [AssetId]) async throws {
        try await priceUpdater.addPrices(assetIds: assetIds)
    }
    
    // MARK: - Private
    
    private func getDeviceAssets(walletId: WalletId, preferences: WalletPreferences) async throws -> [AssetId] {
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        _ = try await deviceService.getSubscriptionsDeviceId()

        return try await discoverAssetService.getAssets(
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
    }
    
    private func enableAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await assetService.prefetchAssets(assetIds: assetIds)
        try await assetsEnabler.enableAssets(walletId: walletId, assetIds: assetIds, enabled: true)
    }
    
    private func setCompleteInitialLoadAssets(preferences: WalletPreferences) {
        preferences.completeInitialLoadAssets = true
        preferences.assetsTimestamp = Int(Date.now.timeIntervalSince1970)
    }
}
