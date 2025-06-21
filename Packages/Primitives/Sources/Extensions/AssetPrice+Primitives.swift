// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension AssetPrice {
    public func mapToPrice() -> Price {
        Price(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt
        )
    }
}

extension Price {
    public func mapToAssetPrice(assetId: AssetId) -> AssetPrice {
        AssetPrice(
            assetId: assetId,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt
        )
    }
}
