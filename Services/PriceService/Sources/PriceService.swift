// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store

public struct PriceService: Sendable {
    private let apiService: any GemAPIPriceService
    private let priceStore: PriceStore
    private let preferences: Preferences
    
    public init(
        apiService: any GemAPIPriceService = GemAPIService(),
        priceStore: PriceStore,
        preferences: Preferences
    ) {
        self.apiService = apiService
        self.priceStore = priceStore
        self.preferences = preferences
    }

    public func updatePrices(assetIds: [String]) async throws {
        let prices = try await fetchPrices(for: assetIds)
        try updatePrices(prices: prices)
    }

    public func updatePrices(prices: [AssetPrice]) throws {
        try priceStore.updatePrices(prices: prices)
    }

    public func updatePrice(price: AssetPrice) throws {
        try priceStore.updatePrice(price: price)
    }

    public func updateMarketPrice(assetId: AssetId, market: AssetMarket) throws {
        try priceStore.updateMarket(assetId: assetId.identifier, market: market)
    }

    public func getPrice(for assetId: AssetId) throws -> AssetPrice? {
        try priceStore.getPrices(for: [assetId.identifier]).first
    }
    
    public func getPrices(for assetIds: [AssetId]) throws -> [AssetPrice] {
        try priceStore.getPrices(for: assetIds.map { $0.identifier })
    }
    
    public func fetchPrices(for assetIds: [String]) async throws -> [AssetPrice] {
        guard !assetIds.isEmpty else { return [] }
        return try await apiService.getPrice(assetIds: assetIds, currency: preferences.currency)
    }
    
    @discardableResult
    public func clear() throws -> Int {
        try priceStore.clear()
    }
}
