// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style
import Formatters
import Components

public struct ChartPriceModel {
    public let period: ChartPeriod
    public let date: Date?
    public let price: Double
    public let priceChange: Double
    public let priceChangePercentage: Double
    public let currency: Currency
    
    public init(
        period: ChartPeriod,
        date: Date?,
        price: Double,
        priceChange: Double,
        priceChangePercentage: Double,
        currency: Currency = Currency.default
    ) {
        self.period = period
        self.date = date
        self.price = price
        self.priceChange = priceChange
        self.priceChangePercentage = priceChangePercentage
        self.currency = currency
    }
    
    public var dateText: String? {
        guard let date = date else { return nil }
        
        switch period {
        case .hour:
            return date.formatted(.dateTime.hour().minute())
        case .day:
            return date.formatted(.dateTime.weekday(.abbreviated).hour().minute())
        case .week, .month:
            return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        case .year, .all:
            return date.formatted(.dateTime.year().month(.abbreviated).day())
        }
    }
    
    public var priceText: String {
        CurrencyFormatter(currencyCode: currency.rawValue).string(price)
    }
    
    public var priceChangeText: String? {
        CurrencyFormatter.percent.string(priceChangePercentage)
    }
    
    public var priceChangeTextColor: Color {
        PriceChangeColor.color(for: priceChange)
    }
}

extension ChartPriceView {
    public static func from(model: ChartPriceModel) -> some View {
        ChartPriceView(
            date: model.dateText,
            price: model.priceText,
            priceChange: model.priceChangeText,
            priceChangeTextColor: model.priceChangeTextColor
        )
    }
}
