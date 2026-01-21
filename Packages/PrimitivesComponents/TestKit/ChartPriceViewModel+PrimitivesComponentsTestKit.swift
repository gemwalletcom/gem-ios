// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Formatters
import Primitives
@testable import PrimitivesComponents

public extension ChartPriceViewModel {
    static func mock(
        period: ChartPeriod = .day,
        date: Date? = nil,
        price: Double = 100,
        priceChangePercentage: Double = 5,
        type: ChartValueType = .price
    ) -> ChartPriceViewModel {
        ChartPriceViewModel(
            period: period,
            date: date,
            price: price,
            priceChangePercentage: priceChangePercentage,
            formatter: CurrencyFormatter(type: .currency, currencyCode: "USD"),
            type: type
        )
    }
}
