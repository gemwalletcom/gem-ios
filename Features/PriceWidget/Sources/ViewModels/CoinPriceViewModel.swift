// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Formatters
import Style

public struct CoinPriceViewModel {
    private let coin: CoinPrice
    private let currency: String
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter = CurrencyFormatter.percent
    
    public init(coin: CoinPrice, currency: String) {
        self.coin = coin
        self.currency = currency
        self.currencyFormatter = CurrencyFormatter(currencyCode: currency)
    }
    
    public var name: String {
        coin.name
    }
    
    public var symbol: String {
        coin.symbol
    }
    
    public var imageURL: URL? {
        coin.imageURL
    }
    
    public var priceText: String {
        currencyFormatter.string(coin.price)
    }
    
    public var percentageText: String {
        percentFormatter.string(coin.priceChangePercentage24h)
    }
    
    public var percentageColor: Color {
        if coin.priceChangePercentage24h > 0 {
            return Colors.green
        } else if coin.priceChangePercentage24h < 0 {
            return Colors.red
        } else {
            return Colors.gray
        }
    }
}
