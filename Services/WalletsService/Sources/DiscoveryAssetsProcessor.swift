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
        async let coinProcess: () = processCoinDiscovery(for: wallet, preferences: preferences)
        async let tokenProcess: () = processTokenDiscovery(for: wallet, preferences: preferences)
        _ = try await (coinProcess, tokenProcess)
        
        WalletPreferences(walletId: walletId.id).completeAssetDiscovery()
    }
    
    // MARK: - Private methods

    private func processCoinDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        // Only perform coin discovery if it hasn’t been done before.
        guard !preferences.completeInitialLoadAssets else { return }

        let coinUpdates = await discoverAssetService.updateCoins(wallet: wallet)
        await processAssetUpdate(for: coinUpdates)
        preferences.completeInitialLoadAssets = true
    }

    private func processTokenDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let tokenUpdate = try await discoverAssetService.updateTokens(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        preferences.assetsTimestamp = newTimestamp
        await processAssetUpdate(for: tokenUpdate)
    }
    
    private func processAssetUpdate(for update: AssetUpdate) async {
        do {
            try assetsService.updateEnabled(walletId: update.walletId, assetIds: update.assetIds, enabled: true)
            try await priceUpdater.addPrices(assetIds: update.assetIds)
        } catch {
            NSLog("add new assets error: \(error)")
        }
    }
}
