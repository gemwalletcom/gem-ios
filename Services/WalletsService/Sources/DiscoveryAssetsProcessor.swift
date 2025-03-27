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
        async let coinProcess: () = processCoinDiscovery(for: wallet, preferences: preferences)
        async let tokenProcess: () = {
            // FIXME: temp solution to wait for 1 second (need to wait until subscriptions updated)
            // otherwise it would return no assets
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await processTokenDiscovery(for: wallet, preferences: preferences)
        }()
        _ = try await (coinProcess, tokenProcess)
    }

    private func processCoinDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        // Only perform coin discovery if it hasn’t been done before.
        guard !preferences.completeInitialLoadAssets else { return }

        let coinUpdates = await discoverAssetService.updateCoins(wallet: wallet)
        await processAssetUpdates(coinUpdates)
        preferences.completeInitialLoadAssets = true
    }

    private func processTokenDiscovery(for wallet: Wallet, preferences: WalletPreferences) async throws {
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let tokenUpdates = try await discoverAssetService.updateTokens(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        preferences.assetsTimestamp = newTimestamp
        await processAssetUpdates(tokenUpdates)
    }

    private func processAssetUpdates(_ updates: [AssetUpdate]) async {
        await withTaskGroup(of: Void.self) { group in
            for update in updates {
                group.addTask {
                    NSLog("discover assets: \(update.walletId): \(update.assets)")
                    do {
                        try await addNewAssets(
                            walletId: update.walletId,
                            assetIds: update.assets.compactMap { try? AssetId(id: $0) }
                        )
                    } catch {
                        NSLog("newAssetUpdate error: \(error)")
                    }
                }
            }
            for await _ in group { }
        }
    }

    // add fresh new asset: fetch asset and then activate balance
    private func addNewAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        let assets = try assetsService.getAssets(for: assetIds)
        let missingIds = assetIds.asSet().subtracting(assets.map { $0.id }.asSet())

        async let enableExisting: () = assetsEnabler.enableAssets(walletId: walletId, assetIds: assets.assetIds, enabled: true)
        async let processMissing: () = withThrowingTaskGroup(of: Void.self) { group in
            for assetId in missingIds {
                group.addTask {
                    try await assetsService.updateAsset(assetId: assetId)
                    await assetsEnabler.enableAssets(walletId: walletId, assetIds: [assetId], enabled: true)
                }
            }
            for try await _ in group { }
        }
        _ = try await (enableExisting, processMissing)
    }
}
