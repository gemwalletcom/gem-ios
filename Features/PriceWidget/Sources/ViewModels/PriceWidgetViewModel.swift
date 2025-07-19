// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Components
import Formatters

@Observable
final class PriceWidgetViewModel {
    let entry: PriceWidgetEntry
    let widgetFamily: WidgetFamily
    let currencyFormatter: CurrencyFormatter
    init(
        entry: PriceWidgetEntry,
        widgetFamily: WidgetFamily
    ) {
        self.entry = entry
        self.widgetFamily = widgetFamily
        self.currencyFormatter = CurrencyFormatter(currencyCode: entry.currency)
    }
    
    var prices: [CoinPrice] {
        switch widgetFamily {
        case .systemSmall:
            return Array(entry.coinPrices.prefix(1))
        case .systemMedium:
            return Array(entry.coinPrices.prefix(3))
        case .systemLarge:
            return entry.coinPrices
        default:
            return entry.coinPrices
        }
    }
}
