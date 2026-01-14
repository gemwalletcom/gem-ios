// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct AssetSearchService: Sendable {
    private let assetsService: AssetsService
    private let searchStore: SearchStore

    public init(
        assetsService: AssetsService,
        searchStore: SearchStore
    ) {
        self.assetsService = assetsService
        self.searchStore = searchStore
    }

    public func searchAssets(
        wallet: Wallet,
        query: String,
        priorityAssetsQuery: String?,
        tag: AssetTag?
    ) async throws -> [AssetBasic] {
        let chains: [Chain] = {
            switch wallet.type {
            case .single, .view, .privateKey: [wallet.accounts.first?.chain].compactMap { $0 }
            case .multicoin: []
            }
        }()

        let assets = try await assetsService.searchAssets(
            query: query,
            chains: chains,
            tags: [tag].compactMap { $0 }
        )

        try assetsService.addAssets(assets: assets)

        if let priorityAssetsQuery {
            try searchStore.add(type: .asset, query: priorityAssetsQuery, ids: assets.map { $0.asset.id.identifier })
        }

        try assetsService.addBalancesIfMissing(
            walletId: wallet.walletId,
            assetIds: assets.map { $0.asset.id }
        )

        return assets
    }
}
