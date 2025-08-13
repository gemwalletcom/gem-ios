// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ServicePrimitives
import Primitives
import Preferences
import Store
import WalletSessionService
import DeviceService

struct DiscoveryAssetsProcessor: DiscoveryAssetsProcessing {
    private let deviceService: any DeviceServiceable
    private let discoverAssetService: DiscoverAssetsService
    private let assetsService: AssetsService
    private let priceUpdater: any PriceUpdater
    private let walletSessionService: any WalletSessionManageable

    init(
        deviceService: any DeviceServiceable,
        discoverAssetService: DiscoverAssetsService,
        assetsService: AssetsService,
        priceUpdater: any PriceUpdater,
        walletSessionService: any WalletSessionManageable
    ) {
        self.deviceService = deviceService
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

        for await coinUpdate in discoverAssetService.updateCoins(wallet: wallet) {
            await processAssetUpdate(for: coinUpdate)
        }
        preferences.completeInitialLoadAssets = true
    }

    private func processTokenDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        let deviceId = try await deviceService.getSubscriptionsDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let tokenUpdateStream = try await discoverAssetService.updateTokens(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        preferences.assetsTimestamp = newTimestamp
        for await tokenUpdate in tokenUpdateStream {
            await processAssetUpdate(for: tokenUpdate)
        }
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
