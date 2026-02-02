// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemAPI
import Preferences

public struct WalletSearchService: Sendable {
    private let assetsService: AssetsService
    private let searchStore: SearchStore
    private let perpetualStore: PerpetualStore
    private let priceStore: PriceStore
    private let preferences: Preferences
    private let searchProvider: any GemAPISearchService

    public init(
        assetsService: AssetsService,
        searchStore: SearchStore,
        perpetualStore: PerpetualStore,
        priceStore: PriceStore,
        preferences: Preferences,
        searchProvider: any GemAPISearchService = GemAPIService.shared
    ) {
        self.assetsService = assetsService
        self.searchStore = searchStore
        self.perpetualStore = perpetualStore
        self.priceStore = priceStore
        self.preferences = preferences
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
        let prices: [AssetPrice] = response.assets.compactMap { asset in
            guard let price = asset.price else { return nil }
            return AssetPrice(
                assetId: asset.asset.id,
                price: price.price,
                priceChangePercentage24h: price.priceChangePercentage24h,
                updatedAt: price.updatedAt
            )
        }

        try assetsService.addAssets(assets: response.assets)
        try priceStore.updatePrices(prices: prices, currency: preferences.currency)
        if tag == nil {
            try assetsService.addAssets(assets: response.perpetuals.map(\.assetBasic))
            try perpetualStore.upsertPerpetuals(response.perpetuals.map(\.perpetual))
        }
        try assetsService.addBalancesIfMissing(
            walletId: wallet.walletId,
            assetIds: response.assets.map { $0.asset.id }
        )

        let searchKey = tag.map { query.isEmpty ? "tag:\($0.rawValue)" : query } ?? query
        try searchStore.add(type: .asset, query: searchKey, ids: response.assets.map { $0.asset.id.identifier })
        if tag == nil {
            try searchStore.add(type: .perpetual, query: searchKey, ids: response.perpetuals.map(\.perpetual.id))
        }
    }
}
