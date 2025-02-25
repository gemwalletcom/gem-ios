// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import Preferences
import Primitives

struct PriceUpdateService: PriceUpdater {
    private let priceService: PriceService
    private let preferences: Preferences

    public init(
        priceService: PriceService,
        preferences: Preferences
    ) {
        self.priceService = priceService
        self.preferences = preferences
    }

    public func updatePrices(assetIds: [AssetId]) async throws {
        let prices = try await priceService.fetchPrices(
            for: assetIds.ids,
            currency: preferences.currency
        )
        try priceService.updatePrices(prices: prices)
    }

    public func clear() throws {
        try priceService.clear()
    }
}
