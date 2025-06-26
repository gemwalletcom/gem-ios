// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import DiscoverAssetsService
import Primitives
import Preferences
import Store
import WalletSessionService

struct DiscoveryAssetsProcessor: DiscoveryAssetsProcessing {
    private let discoverAssetService: DiscoverAssetsService
    private let assetsService: AssetsService
    private let priceUpdater: any PriceUpdater
    private let walletSessionService: any WalletSessionManageable

    init(
        discoverAssetService: DiscoverAssetsService,
        assetsService: AssetsService,
        priceUpdater: any PriceUpdater,
        walletSessionService: any WalletSessionManageable
    ) {
        self.discoverAssetService = discoverAssetService
        self.assetsService = assetsService
        self.priceUpdater = priceUpdater
        self.walletSessionService = walletSessionService
    }

    func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        let wallet = try walletSessionService.getWallet(walletId: walletId)
        // FIXME: temp solution to wait for 1 second (need to wait until subscriptions updated)
        // otherwise it would return no assets
        try await Task.sleep(nanoseconds: 1_000_000_000)
        try await processDiscovery(for: wallet, preferences: preferences)
    }

    private func processDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let update = try await discoverAssetService.updateBalance(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        preferences.assetsTimestamp = newTimestamp
        await updateEnabled(for: update)
        preferences.isDiscoveredAssets = true
    }

    private func updateEnabled(for update: AssetUpdate) async {
        do {
            try assetsService.updateEnabled(walletId: update.walletId, assetIds: update.assetIds, enabled: true)
            try await priceUpdater.addPrices(assetIds: update.assetIds)
        } catch {
            NSLog("add new assets error: \(error)")
        }
    }
}
