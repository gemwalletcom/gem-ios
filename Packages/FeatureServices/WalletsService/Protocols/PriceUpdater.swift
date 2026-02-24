// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceService

public protocol PriceUpdater: Sendable {
    func addPrices(assetIds: [AssetId]) async throws
}

extension PriceObserverService: PriceUpdater {
    public func addPrices(assetIds: [AssetId]) async throws {
        try await addAssets(assets: assetIds)
    }
}
