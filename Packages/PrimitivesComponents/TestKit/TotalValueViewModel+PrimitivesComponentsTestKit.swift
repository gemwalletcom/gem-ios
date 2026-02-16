// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Primitives
import PrimitivesTestKit
import PrimitivesComponents

public extension TotalValueViewModel {
    static func mock(
        value: Double = 1000,
        pnlAmount: Double = 50,
        pnlPercentage: Double = 5
    ) -> TotalValueViewModel {
        TotalValueViewModel(
            totalValue: .mock(value: value, pnlAmount: pnlAmount, pnlPercentage: pnlPercentage),
            currencyFormatter: CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        )
    }
}
