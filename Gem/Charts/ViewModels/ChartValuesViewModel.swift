// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Charts
import MarketInsight

public struct ChartValuesViewModel {

    let period: ChartPeriod
    let price: Price?
    let values: ChartValues
    let formatter = CurrencyFormatter.currency()
    
    static let defaultPeriod = ChartPeriod.day

    init(
        period: ChartPeriod,
        price: Price?,
        values: ChartValues
    ) {
        self.period = period
        self.price = price
        self.values = values
    }
    
    public var charts: [ChartDateValue] {
        return values.charts
    }
    
    public var lowerBoundValueText: String {
        return formatter.string(values.lowerBoundValue)
    }
    
    public var upperBoundValueText: String {
        return formatter.string(values.upperBoundValue)
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
