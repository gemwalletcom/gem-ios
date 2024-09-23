import Foundation
import Primitives
import SwiftHTTPClient
import GemAPI
import Store

public struct PriceService {
    
    let provider = Provider<GemAPI>()
    let priceStore: PriceStore
    let preferences: Preferences

    var currency: String {
        return preferences.currency
    }
    
    public init(
        priceStore: PriceStore,
        preferences: Preferences = .standard
    ) {
        self.priceStore = priceStore
        self.preferences = preferences
    }

    public func updatePrices(assetIds: [String]) async throws {
        let prices = try await fetchPrices(for: assetIds)
        try updatePrices(prices: prices)
    }

    public func updatePrices(prices: [AssetPrice]) throws {
        return try priceStore.updatePrices(prices: prices)
    }
    
    public func getPrice(for assetId: AssetId) throws -> AssetPrice? {
        return try priceStore.getPrices(for: [assetId.identifier]).first
    }
    
    public func getPrices(for assetIds: [AssetId]) throws -> [AssetPrice] {
        return try priceStore.getPrices(for: assetIds.map { $0.identifier })
    }
    
    public func fetchPrices(for assetIds: [String]) async throws -> [Primitives.AssetPrice] {
        guard !assetIds.isEmpty else { return [] }
        
        let request = AssetPricesRequest(currency: currency, assetIds: assetIds)
        
        return try await provider
            .request(.getPrices(request))
            .map(as: AssetPrices.self).prices
    }
    
    @discardableResult
    func clear() throws -> Int {
        return try priceStore.clear()
    }
}
