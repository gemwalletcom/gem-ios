// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import DiscoverAssetsService
import Primitives
import Preferences
import DeviceService

public actor AssetDiscoveryService: AssetDiscoverable {
    private let deviceService: any DeviceServiceable
    private let discoverAssetService: DiscoverAssetsService
    private let assetService: AssetsService
    private let assetsEnabler: any AssetsEnabler

    public init(
        deviceService: any DeviceServiceable,
        discoverAssetService: DiscoverAssetsService,
        assetService: AssetsService,
        assetsEnabler: any AssetsEnabler
    ) {
        self.deviceService = deviceService
        self.discoverAssetService = discoverAssetService
        self.assetService = assetService
        self.assetsEnabler = assetsEnabler
    }

    public func discoverAssets(wallet: Wallet) async throws {
        let preferences = WalletPreferences(walletId: wallet.walletId)
        _ = try await deviceService.getSubscriptionsDeviceId()

        let assetIds = try await discoverAssetService.getAssets(wallet: wallet, fromTimestamp: preferences.assetsTimestamp)

        if assetIds.isNotEmpty {
            try await assetService.prefetchAssets(assetIds: assetIds)
            try await assetsEnabler.enableAssets(walletId: wallet.walletId, assetIds: assetIds, enabled: true)
        }

        preferences.completeInitialLoadAssets = true
        preferences.assetsTimestamp = Int(Date.now.timeIntervalSince1970)
    }
}
