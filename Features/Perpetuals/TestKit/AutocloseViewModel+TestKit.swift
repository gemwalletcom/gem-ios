// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import Perpetuals

public extension AutocloseViewModel {
    static func mock(
        type: TpslType = .takeProfit,
        price: Double? = nil,
        estimator: AutocloseEstimator = .mock(),
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: "USD"),
        percentFormatter: CurrencyFormatter = .percent
    ) -> AutocloseViewModel {
        AutocloseViewModel(
            type: type,
            price: price,
            estimator: estimator,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }
}
