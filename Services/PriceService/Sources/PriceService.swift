// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store

public struct PriceService: Sendable {
    private let apiService: any GemAPIPriceService
    private let priceStore: PriceStore
    private let formatter: ValueFormatter
    
    public init(
        apiService: any GemAPIPriceService = GemAPIService(),
        priceStore: PriceStore,
        formatter: ValueFormatter = ValueFormatter(style: .medium)
    ) {
        self.apiService = apiService
        self.priceStore = priceStore
        self.formatter = formatter
    }

    public func updatePrices(assetIds: [String], currency: String) async throws {
        let prices = try await fetchPrices(for: assetIds, currency: currency)
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
    
    public func fetchPrices(for assetIds: [String], currency: String) async throws -> [AssetPrice] {
        guard !assetIds.isEmpty else { return [] }
        return try await apiService.getPrice(assetIds: assetIds, currency: currency)
    }
    
    @discardableResult
    public func clear() throws -> Int {
        try priceStore.clear()
    }

    public func convertToFiat(amount: String, asset: Asset) throws -> Decimal {
        guard let assetPrice = try getPrice(for: asset.id) else {
            throw AnyError("Price not found")
        }
        let value = try formatter.number(amount: amount)
        return value * Decimal(assetPrice.price)
    }

    public func convertToAmount(fiatValue: String, asset: Asset) throws -> String {
        let fiatNumber = try formatter.number(amount: fiatValue)
        let price = try getPrice(for: asset.id)
        let assetAmount = try calculateAssetAmount(fiat: fiatNumber, price: price)
        return try formatAssetAmount(assetAmount, asset: asset)
    }

    // MARK: - Private methods

    private func calculateAssetAmount(fiat: Decimal, price: AssetPrice?) throws -> Decimal {
        guard let price, price.price > 0 else {
            throw AnyError("Price not found")
        }
        return fiat / Decimal(price.price)
    }

    private func formatAssetAmount(_ tokenAmount: Decimal, asset: Asset) throws -> String {
        let inputNumber = try formatter.inputNumber(from: tokenAmount.description, decimals: asset.decimals.asInt)
        guard !inputNumber.isZero else {
            throw AnyError("Cannot format zero amount")
        }
        return formatter.string(inputNumber, decimals: asset.decimals.asInt)
    }
}
