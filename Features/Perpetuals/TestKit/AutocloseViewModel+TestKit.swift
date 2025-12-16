// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import Perpetuals

public extension AutocloseViewModel {
    static func mock(
        type: TpslType = .takeProfit,
        price: Double? = nil,
        positionSize: Double = 10.0,
        leverage: UInt8 = 5,
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: "USD"),
        percentFormatter: CurrencyFormatter = .percent
    ) -> AutocloseViewModel {
        AutocloseViewModel(
            type: type,
            price: price,
            estimator: .mock(positionSize: positionSize, leverage: leverage),
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }
}
