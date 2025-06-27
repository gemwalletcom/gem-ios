// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Charts
import Preferences
import Formatters

public struct ChartValuesViewModel: Sendable {
    let period: ChartPeriod
    let price: Price?
    let values: ChartValues
    let formatter = CurrencyFormatter(currencyCode: Preferences.standard.currency)

    public static let defaultPeriod = ChartPeriod.day

    public init(
        period: ChartPeriod,
        price: Price?,
        values: ChartValues
    ) {
        self.period = period
        self.price = price
        self.values = values
    }
    
    public var charts: [ChartDateValue] {
        values.charts
    }
    
    public var lowerBoundValueText: String {
        formatter.string(values.lowerBoundValue)
    }
    
    public var upperBoundValueText: String {
        formatter.string(values.upperBoundValue)
    }
    
    var chartPriceModel: ChartPriceModel? {
        if let price {
            if period == Self.defaultPeriod {
                return ChartPriceModel(
                    period: period,
                    date: .none,
                    price: price.price,
                    priceChange: price.priceChangePercentage24h
                )
            } else {
                let change = values.priceChange(base: values.firstValue, price: price.price)
                return ChartPriceModel(period: period, date: .none, price: change.price, priceChange: change.priceChange)
            }
        }
        return .none
    }
}
