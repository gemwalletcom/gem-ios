// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

struct ChartPriceModel {
    
    let period: ChartPeriod
    let date: Date?
    let price: Double
    let priceChange: Double
    
    private let formatterPrice = CurrencyFormatter.currency()
    private let formatterPercent = CurrencyFormatter.percent()
    
    var dateText: String? {
        if let date {
            return ChartDateFormatter(period: period, date: date).dateText
        }
        return .none
    }
    
    var priceText: String {
        formatterPrice.string(price)
    }
    
    var priceChangeText: String? {
        return formatterPercent.string(priceChange)
    }
    
    var priceChangeTextColor: Color {
        PriceViewModel.priceChangeTextColor(value: priceChange)
    }
}
