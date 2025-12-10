// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WidgetKit
import Primitives
import Style

internal struct PriceWidgetEntry: TimelineEntry, Sendable {
    let date: Date
    let coinPrices: [CoinPrice]
    let currency: String
    let error: String?
    let widgetFamily: WidgetFamily

    init(
        date: Date,
        coinPrices: [CoinPrice],
        currency: String = "USD",
        error: String? = .none,
        widgetFamily: WidgetFamily = .systemMedium
    ) {
        self.date = date
        self.coinPrices = coinPrices
        self.currency = currency
        self.error = error
        self.widgetFamily = widgetFamily
    }

    static func error(error: String, widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: [],
            error: error,
            widgetFamily: widgetFamily
        )
    }

    static func placeholder(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        let placeholderCoins = [
            CoinPrice(
                assetId: AssetId(chain: .bitcoin, tokenId: nil),
                name: "Bitcoin",
                symbol: "BTC",
                price: 69000,
                priceChangePercentage24h: 2.5,
                image: Images.name(Chain.bitcoin.rawValue)
            ),
            CoinPrice(
                assetId: AssetId(chain: .ethereum, tokenId: nil),
                name: "Ethereum",
                symbol: "ETH",
                price: 3500,
                priceChangePercentage24h: 1.2,
                image: Images.name(Chain.ethereum.rawValue)
            ),
            CoinPrice(
                assetId: AssetId(chain: .solana, tokenId: nil),
                name: "Solana",
                symbol: "SOL",
                price: 150,
                priceChangePercentage24h: -0.8,
                image: Images.name(Chain.solana.rawValue)
            )
        ]

        return PriceWidgetEntry(
            date: Date(),
            coinPrices: widgetFamily == .systemSmall ? Array(placeholderCoins.prefix(1)) : placeholderCoins,
            error: .none,
            widgetFamily: widgetFamily
        )
    }
}
