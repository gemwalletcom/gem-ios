// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletsService

public struct PriceUpdaterMock: PriceUpdater {
    public init() {}

    public func addPrices(assetIds: [AssetId]) async throws {}
}

public extension PriceUpdater where Self == PriceUpdaterMock {
    static func mock() -> PriceUpdaterMock {
        PriceUpdaterMock()
    }
}
