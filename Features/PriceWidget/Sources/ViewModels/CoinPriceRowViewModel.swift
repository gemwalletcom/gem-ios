// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Formatters
import Style

struct CoinPriceRowViewModel {
    private let coin: CoinPrice
    private let currency: String
    private let currencyFormatter = CurrencyFormatter()
    private let percentFormatter = CurrencyFormatter.percent
    
    init(coin: CoinPrice, currency: String) {
        self.coin = coin
        self.currency = currency
    }
    
    var name: String {
        coin.name
    }
    
    var symbol: String {
        coin.symbol
    }
    
    var imageURL: URL? {
        coin.imageURL
    }
    
    var priceText: String {
        currencyFormatter.string(
            coin.price
        )
    }
    
    var percentageText: String {
        percentFormatter.string(coin.priceChangePercentage24h)
    }
    
    var percentageColor: Color {
        if coin.priceChangePercentage24h > 0 {
            return Colors.green
        } else if coin.priceChangePercentage24h < 0 {
            return Colors.red
        } else {
            return Colors.gray
        }
    }
}
