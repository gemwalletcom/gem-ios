// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Formatters
import Style
import Components

@Observable
@MainActor
internal final class CoinPriceRowViewModel {
    private let coin: CoinPrice
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter

    internal init(
        coin: CoinPrice,
        currencyFormatter: CurrencyFormatter,
        percentFormatter: CurrencyFormatter
    ) {
        self.coin = coin
        self.currencyFormatter = currencyFormatter
        self.percentFormatter = percentFormatter
    }

    var name: String {
        coin.name
    }

    var symbol: String {
        coin.symbol
    }

    var assetImage: AssetImage {
        AssetImage(
            type: coin.symbol,
            placeholder: coin.image,
            chainPlaceholder: chainPlaceholder
        )
    }
    
    var chainPlaceholder: Image? {
        switch coin.assetId.type {
        case .native: nil
        case .token: Images.name(coin.assetId.chain.rawValue)
        }
    }

    var priceText: String {
        currencyFormatter.string(coin.price)
    }

    var percentageText: String {
        percentFormatter.string(coin.priceChangePercentage24h)
    }

    var percentageColor: Color {
        PriceChangeColor.color(for: coin.priceChangePercentage24h)
    }

    var percentageChange: Double {
        coin.priceChangePercentage24h
    }
}
