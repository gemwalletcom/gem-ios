// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

public struct CoinPrice: Sendable, Identifiable {
    public let assetId: AssetId
    public let name: String
    public let symbol: String
    public let price: Double
    public let priceChangePercentage24h: Double
    public let imageURL: URL?
    
    public var id: AssetId { assetId }
    
    public init(
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
    
    public static func placeholders() -> [CoinPrice] {
        let placeholders: [(Chain, String, String, Double, Double)] = [
            (.bitcoin, "Bitcoin", "BTC", 169000, 4.20),
            (.ethereum, "Ethereum", "ETH", 5120, 1.2),
            (.solana, "Solana", "SOL", 159, 5.3),
            (.xrp, "XRP", "XRP", 2.65, 0.8),
            (.smartChain, "BNB", "BNB", 699, 2.5),
        ]
        
        return placeholders.map { chain, name, symbol, price, change in
            return CoinPrice(
                assetId: chain.assetId,
                name: name,
                symbol: symbol,
                price: price,
                priceChangePercentage24h: change,
                imageURL: AssetImageFormatter().getURL(for: chain.assetId)
            )
        }
    }
}
