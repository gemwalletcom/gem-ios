// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import DiscoverAssetsService
import Primitives
import Preferences
import Store
import WalletSessionService
import DeviceService

struct DiscoveryAssetsProcessor: DiscoveryAssetsProcessing {
    private let deviceService: any DeviceServiceable
    private let discoverAssetService: DiscoverAssetsService
    private let priceUpdater: any PriceUpdater
    private let walletSessionService: any WalletSessionManageable
    private let assetsEnabler: any AssetsEnabler

    init(
        deviceService: any DeviceServiceable,
        discoverAssetService: DiscoverAssetsService,
        priceUpdater: any PriceUpdater,
        walletSessionService: any WalletSessionManageable,
        assetsEnabler: any AssetsEnabler
    ) {
        self.deviceService = deviceService
        self.discoverAssetService = discoverAssetService
        self.priceUpdater = priceUpdater
        self.walletSessionService = walletSessionService
        self.assetsEnabler = assetsEnabler
    }

    func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        // Only perform coin discovery if it hasn’t been done before.
        guard !preferences.completeInitialLoadAssets else { return }
        
        let deviceId = try await deviceService.getSubscriptionsDeviceId()
        let assetIds = try await discoverAssetService.getAssets(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        try await priceUpdater.addPrices(assetIds: assetIds)
        await assetsEnabler.enableAssets(walletId: wallet.walletId, assetIds: assetIds, enabled: true)
        
        preferences.completeInitialLoadAssets = true
    }
}
