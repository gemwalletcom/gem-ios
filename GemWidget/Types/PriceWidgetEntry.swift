// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WidgetKit
import Primitives
import GemstonePrimitives

struct PriceWidgetEntry: TimelineEntry {
    let date: Date
    let coinPrices: [CoinPrice]
    let currency: String
    
    static func empty() -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: [],
            currency: "USD"
        )
    }
    
    static func placeholder() -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: CoinPrice.placeholders(),
            currency: "USD"
        )
    }
}

struct CoinPrice: Sendable {
    let assetId: AssetId
    let name: String
    let symbol: String
    let price: Double
    let priceChangePercentage24h: Double
    let imageURL: URL?
    
    static func placeholders() -> [CoinPrice] {
        let placeholders: [(Chain, String, String, Double, Double)] = [
            (.bitcoin, "Bitcoin", "BTC", 45000, 2.5),
            (.ethereum, "Ethereum", "ETH", 2500, -1.2),
            (.solana, "Solana", "SOL", 150, 5.3),
            (.xrp, "XRP", "XRP", 0.65, 0.8),
            (.smartChain, "BNB", "BNB", 320, -0.5),
        ]
        
        return placeholders.map { chain, name, symbol, price, change in
            let assetId = AssetId(chain: chain, tokenId: nil)
            return CoinPrice(
                assetId: assetId,
                name: name,
                symbol: symbol,
                price: price,
                priceChangePercentage24h: change,
                imageURL: AssetImageFormatter.url(for: assetId)
            )
        }
    }
}
