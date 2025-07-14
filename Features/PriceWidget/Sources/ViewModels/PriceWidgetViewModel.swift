// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit

@Observable
final class PriceWidgetViewModel {
    let entry: PriceWidgetEntry
    let widgetFamily: WidgetFamily
    
    init(entry: PriceWidgetEntry, widgetFamily: WidgetFamily) {
        self.entry = entry
        self.widgetFamily = widgetFamily
    }
    
    var displayedCoins: [CoinPrice] {
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
    
    var hasData: Bool {
        !entry.coinPrices.isEmpty
    }
}
