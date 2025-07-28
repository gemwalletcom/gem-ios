// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Components

@Observable
@MainActor
internal final class PriceWidgetViewModel {
    let entry: PriceWidgetEntry
    let widgetFamily: WidgetFamily
    init(
        entry: PriceWidgetEntry,
        widgetFamily: WidgetFamily
    ) {
        self.entry = entry
        self.widgetFamily = widgetFamily
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
    
    var emptyMessage: String {
        switch widgetFamily {
        case .systemSmall:
            return "No data"
        default:
            return "No price data available"
        }
    }
}
