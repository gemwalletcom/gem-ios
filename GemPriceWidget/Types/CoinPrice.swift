// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

internal struct CoinPrice: Sendable, Identifiable {
    let assetId: AssetId
    let name: String
    let symbol: String
    let price: Double
    let priceChangePercentage24h: Double
    let imageURL: URL?
    
    var id: AssetId { assetId }
    
    init(
        assetId: AssetId,
        name: String,
        symbol: String,
        price: Double,
        priceChangePercentage24h: Double,
        imageURL: URL?
    ) {
        self.assetId = assetId
        self.name = name
        self.symbol = symbol
        self.price = price
        self.priceChangePercentage24h = priceChangePercentage24h
        self.imageURL = imageURL
    }
    
}
