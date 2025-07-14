// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WidgetKit
import Primitives
import GemstonePrimitives

public struct PriceWidgetEntry: TimelineEntry, Sendable {
    public let date: Date
    public let coinPrices: [CoinPrice]
    public let currency: String
    public let widgetFamily: WidgetFamily
    
    public init(date: Date, coinPrices: [CoinPrice], currency: String, widgetFamily: WidgetFamily = .systemMedium) {
        self.date = date
        self.coinPrices = coinPrices
        self.currency = currency
        self.widgetFamily = widgetFamily
    }
    
    public static func empty(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: [],
            currency: "USD",
            widgetFamily: widgetFamily
        )
    }
    
    public static func placeholder(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: CoinPrice.placeholders(),
            currency: "USD",
            widgetFamily: widgetFamily
        )
    }
}

