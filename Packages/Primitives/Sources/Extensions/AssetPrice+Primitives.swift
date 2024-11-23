// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension AssetPrice {
    public func mapToPrice() -> Price {
        return Price(price: price, priceChangePercentage24h: priceChangePercentage24h)
    }
}

extension Price {
    public func mapToAssetPrice(assetId: String) -> AssetPrice {
        return AssetPrice(assetId: assetId, price: price, priceChangePercentage24h: priceChangePercentage24h)
    }
}
