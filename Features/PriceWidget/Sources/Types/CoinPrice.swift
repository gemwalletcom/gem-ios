// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

public struct CoinPrice: Sendable {
    public let assetId: AssetId
    public let name: String
    public let symbol: String
    public let price: Double
    public let priceChangePercentage24h: Double
    public let imageURL: URL?
    
    public init(
        assetId: AssetId,
        name: String,
        symbol: String,
        price: Double,
        priceChangePercentage24h: Double,
        imageURL: URL? = nil
    ) {
        self.assetId = assetId
        self.name = name
        self.symbol = symbol
        self.price = price
        self.priceChangePercentage24h = priceChangePercentage24h
        self.imageURL = imageURL
    }
    
    public static func placeholders() -> [CoinPrice] {
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
                imageURL: AssetImageFormatter().getURL(for: assetId)
            )
        }
    }
}
