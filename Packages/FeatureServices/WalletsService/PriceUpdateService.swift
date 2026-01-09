// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import Preferences
import Primitives

struct PriceUpdateService: PriceUpdater {
    private let priceObserver: PriceObserverService

    public init(
        priceObserver: PriceObserverService
    ) {
        self.priceObserver = priceObserver
    }

    public func addPrices(assetIds: [AssetId]) async throws {
        try await priceObserver.addAssets(assets: assetIds)
    }
}
