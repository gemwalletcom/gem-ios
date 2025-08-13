// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store
import ServicePrimitives

public struct PriceService: Sendable {
    private let priceStore: PriceStore
    private let fiatRateStore: FiatRateStore

    public init(
        priceStore: PriceStore,
        fiatRateStore: FiatRateStore
    ) {
        self.priceStore = priceStore
        self.fiatRateStore = fiatRateStore
    }

    public func updatePrices(_ prices: [AssetPrice], currency: String) throws {
        try priceStore.updatePrices(prices: prices, currency: currency)
    }

    public func updateMarketPrice(assetId: AssetId, market: AssetMarket, currency: String) throws {
        try priceStore.updateMarket(
            assetId: assetId.identifier,
            market: market,
            rate: try getRate(currency: currency)
        )
    }

    public func getPrice(for assetId: AssetId) throws -> AssetPrice? {
        try priceStore.getPrices(for: [assetId.identifier]).first
    }
    
    public func getPrices(for assetIds: [AssetId]) throws -> [AssetPrice] {
        try priceStore.getPrices(for: assetIds.map { $0.identifier })
    }
    
    public func observableAssets() throws -> [AssetId] {
        let priceAssets = try priceStore.enabledPriceAssets()
        if priceAssets.isEmpty {
            return [Chain.bitcoin, Chain.ethereum, Chain.smartChain, Chain.solana].map { $0.assetId }
        }
        return priceAssets
    }
    
    public func changeCurrency(currency: String) throws {
        try priceStore.updateCurrency(currency: currency)
    }
    
    public func getRate(currency: String) throws -> Double {
        try priceStore.getRate(currency: currency).rate
    }
    
    public func addRates(_ rates: [FiatRate]) throws {
        guard rates.isNotEmpty else { return }
        
        try fiatRateStore.add(rates)
    }
    
    @discardableResult
    public func clear() throws -> Int {
        try priceStore.clear()
    }
}

extension PriceService: PriceUpdater {
    public func addPrices(assetIds: [AssetId]) async throws {
        // This would typically fetch prices from an API and then update the store
        // For now, we'll add placeholder prices
        let prices = assetIds.map { assetId in
            AssetPrice(
                assetId: assetId.identifier,
                price: 0.0,
                priceChangePercentage24h: 0.0
            )
        }
        try updatePrices(prices, currency: "USD")
    }
}
