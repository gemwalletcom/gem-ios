// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceWidget
import Primitives
import GemstonePrimitives

public extension PriceWidgetEntry {
    static func mock(
        date: Date = Date(),
        coinPrices: [CoinPrice] = CoinPrice.mocks(),
        currency: String = "USD"
    ) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: date,
            coinPrices: coinPrices,
            currency: currency
        )
    }
}

public extension CoinPrice {
    static func mock(
        assetId: AssetId = AssetId(chain: .bitcoin, tokenId: nil),
        name: String = "Bitcoin",
        symbol: String = "BTC",
        price: Double = 45000,
        priceChangePercentage24h: Double = 2.5,
        imageURL: URL? = nil
    ) -> CoinPrice {
        CoinPrice(
            assetId: assetId,
            name: name,
            symbol: symbol,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            imageURL: imageURL ?? AssetImageFormatter.url(for: assetId)
        )
    }
    
    static func mocks() -> [CoinPrice] {
        [
            .mock(),
            .mock(
                assetId: AssetId(chain: .ethereum, tokenId: nil),
                name: "Ethereum",
                symbol: "ETH",
                price: 2500,
                priceChangePercentage24h: -1.2
            ),
            .mock(
                assetId: AssetId(chain: .solana, tokenId: nil),
                name: "Solana",
                symbol: "SOL",
                price: 150,
                priceChangePercentage24h: 5.3
            ),
        ]
    }
}