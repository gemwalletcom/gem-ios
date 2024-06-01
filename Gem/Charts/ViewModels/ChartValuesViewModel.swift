// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ChartValuesViewModel {
    
    let period: ChartPeriod
    let price: Price?
    let values: ChartValues
    let formatter = CurrencyFormatter.currency()
    
    init(
        period: ChartPeriod,
        price: Price?,
        values: ChartValues
    ) {
        self.period = period
        self.price = price
        self.values = values
    }
    
    var charts: [ChartDateValue] {
        return values.charts
    }
    
    var lowerBoundValueText: String {
        return formatter.string(values.lowerBoundValue)
    }
    
    var upperBoundValueText: String {
        return formatter.string(values.upperBoundValue)
    }
    
    var chartPriceModel: ChartPriceModel? {
        if let price {
            return ChartPriceModel(period: period, date: .none, price: price.price, priceChange: price.priceChangePercentage24h)
        }
        return .none
    }
    
    var currentPrice: Double {
        return price?.price ?? 0
    }
    
    var currentPriceChangeText: String? {
        return price?.priceChangePercentage24h.description
    }
}
