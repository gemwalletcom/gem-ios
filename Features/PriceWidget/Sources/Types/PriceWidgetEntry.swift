// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WidgetKit
import Primitives
import GemstonePrimitives

public struct PriceWidgetEntry: TimelineEntry, Sendable {
    public let date: Date
    public let coinPrices: [CoinPrice]
    public let currency: String
    public let error: String?
    public let widgetFamily: WidgetFamily
    
    public init(
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
    
    public static func empty(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: [],
            error: "Empty",
            widgetFamily: widgetFamily
        )
    }
    
    public static func error(error: String, widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: [],
            error: error,
            widgetFamily: widgetFamily
        )
    }
    
    public static func placeholder(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        PriceWidgetEntry(
            date: Date(),
            coinPrices: CoinPrice.placeholders(),
            error: .none,
            widgetFamily: widgetFamily
        )
    }
}

