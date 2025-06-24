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
    private let assetsEnabler: any AssetsEnabler
    private let walletSessionService: any WalletSessionManageable

    init(
        discoverAssetService: DiscoverAssetsService,
        assetsService: AssetsService,
        assetsEnabler: any AssetsEnabler,
        walletSessionService: any WalletSessionManageable
    ) {
        self.discoverAssetService = discoverAssetService
        self.assetsService = assetsService
        self.assetsEnabler = assetsEnabler
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
        await addNewAssets(for: update)
    }

    // add fresh new asset: fetch asset and then activate balance
    private func addNewAssets(for update: AssetUpdate) async {
        do {
            let assets = try assetsService.getAssets(for: update.assetIds)
            let missingIds = update.assetIds.asSet().subtracting(assets.map { $0.id }.asSet())

            async let enableExisting: () = assetsEnabler.enableAssets(walletId: update.walletId, assetIds: update.assetIds, enabled: true)
            async let processMissing: () = withThrowingTaskGroup(of: Void.self) { group in
                for assetId in missingIds {
                    group.addTask {
                        try await assetsService.updateAsset(assetId: assetId)
                    }
                }
                for try await _ in group { }
                await assetsEnabler.enableAssets(walletId: update.walletId, assetIds: update.assetIds, enabled: true)
            }
            _ = try await (enableExisting, processMissing)
        } catch {
            NSLog("add new assets error: \(error)")
        }
    }
}
