// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Settings
import GemAPI

struct ImportAssetsService {
    let nodeService: NodeService
    let assetListService: GemAPIAssetsListService = GemAPIService()
    let assetsService: AssetsService
    var assetStore: AssetStore
    let preferences: Preferences
    
    // sync
    func migrate() throws {
        let releaseVersionNumber = Bundle.main.buildVersionNumber
        
        #if DEBUG
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
        let assets = try await assetListService.getFiatAssets()

        try await assetsService.prefetchAssets(assetIds: assets.assetIds.compactMap { AssetId(id: $0) })
        try assetStore.setAssetIsBuyable(for: assets.assetIds, value: true)
        
        preferences.fiatAssetsVersion = Int(assets.version)
    }
    
    func updateSwapAssets() async throws {
        let assets = try await assetListService.getSwapAssets()

        try await assetsService.prefetchAssets(assetIds: assets.assetIds.compactMap { AssetId(id: $0) })
        try assetStore.setAssetIsSwappable(for: assets.assetIds, value: true)
    
        preferences.swapAssetsVersion = Int(assets.version)
    }
    
    func updateNodes() async throws {
        let version = try await nodeService.updateNodes()
        preferences.nodesVersion = version
    }
}
