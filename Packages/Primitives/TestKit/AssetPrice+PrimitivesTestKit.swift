// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension AssetPrice {
    public static func mock(
        assetId: AssetId = .mock(),
        price: Double = 1,
        priceChangePercentage24h: Double = 1,
        updatedAt: Date = .now
    ) -> AssetPrice {
        AssetPrice(
            assetId: assetId,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt
        )
    }
}
