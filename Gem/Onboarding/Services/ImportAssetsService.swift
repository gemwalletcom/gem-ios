// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Settings
import GemAPI

struct ImportAssetsService {
    let nodeService: NodeService
    let assetListService: any GemAPIAssetsListService = GemAPIService()
    let assetsService: AssetsService
    var assetStore: AssetStore
    let preferences: Preferences
    
    // sync
    func migrate() throws {
        let releaseVersionNumber = Bundle.main.buildVersionNumber
        
        #if targetEnvironment(simulator)
        #else
        guard preferences.localAssetsVersion < releaseVersionNumber else {
            return
        }
        preferences.localAssetsVersion = releaseVersionNumber
        #endif
        
        let chains = Settings.AssetConfiguration.allChains
        let assetIds = chains.map { $0.id }
        let localAssetsVersion = try assetStore.getAssets(for: assetIds).map { $0.id }
        
        if localAssetsVersion.count != assetIds.count {
            let assets = chains.map {
                AssetFull(
                    asset: $0.asset,
                    details: .none,
                    price: .none,
                    market: .none,
                    score: AssetScore.defaultScore(chain: $0.asset.chain)
                )
            }
            try assetStore.insertFull(assets: assets)
        }
    }

    func updateFiatAssets() async throws {
        async let getBuyAssets = try assetListService.getBuyableFiatAssets()
        async let getSellAssets = try assetListService.getSellableFiatAssets()

        let (buyAssets, sellAssets) = try await (getBuyAssets, getSellAssets)

        let assetIds = (buyAssets.assetIds + sellAssets.assetIds).compactMap { try? AssetId(id: $0) }

        async let prefetchResult = try assetsService.prefetchAssets(assetIds: assetIds)
        async let setBuyableResult = try assetStore.setAssetIsBuyable(for: buyAssets.assetIds, value: true)
        async let setSellableResult = try assetStore.setAssetIsSellable(for: sellAssets.assetIds, value: true)

        _ = try await (prefetchResult, setBuyableResult, setSellableResult)

        preferences.fiatAssetsVersion = Int(max(buyAssets.version, sellAssets.version))
    }

    func updateSwapAssets() async throws {
        let assets = try await assetListService.getSwapAssets()

        try await assetsService.prefetchAssets(assetIds: assets.assetIds.compactMap { try? AssetId(id: $0) })
        try assetStore.setAssetIsSwappable(for: assets.assetIds, value: true)
    
        preferences.swapAssetsVersion = Int(assets.version)
    }
}
