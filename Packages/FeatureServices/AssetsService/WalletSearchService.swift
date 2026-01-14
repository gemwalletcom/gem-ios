// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemAPI

public struct WalletSearchService: Sendable {
    private let assetsService: AssetsService
    private let searchStore: SearchStore
    private let perpetualStore: PerpetualStore
    private let searchProvider: any GemAPISearchService

    public init(
        assetsService: AssetsService,
        searchStore: SearchStore,
        perpetualStore: PerpetualStore,
        searchProvider: any GemAPISearchService = GemAPIService.shared
    ) {
        self.assetsService = assetsService
        self.searchStore = searchStore
        self.perpetualStore = perpetualStore
        self.searchProvider = searchProvider
    }

    public func search(wallet: Wallet, query: String, tag: AssetTag? = nil) async throws {
        let chains: [Chain] = {
            switch wallet.type {
            case .single, .view, .privateKey: [wallet.accounts.first?.chain].compactMap { $0 }
            case .multicoin: []
            }
        }()

        let response = try await searchProvider.search(query: query, chains: chains, tags: [tag].compactMap { $0 })
        let searchKey = tag.map { query.isEmpty ? "tag:\($0.rawValue)" : query } ?? query

        try assetsService.addAssets(assets: response.assets)
        try searchStore.add(type: .asset, query: searchKey, ids: response.assets.map { $0.asset.id.identifier })
        try perpetualStore.upsertPerpetuals(response.perpetuals)
        if tag == nil {
            try searchStore.add(type: .perpetual, query: searchKey, ids: response.perpetuals.map(\.id))
        }
        try assetsService.addBalancesIfMissing(
            walletId: wallet.walletId,
            assetIds: response.assets.map { $0.asset.id }
        )
    }
}
