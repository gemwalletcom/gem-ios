// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Formatters
import Primitives
import PrimitivesComponents

public extension PriceChangeViewModel {
    static func mock(value: Double?) -> PriceChangeViewModel {
        PriceChangeViewModel(
            value: value,
            currencyFormatter: CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
        )
    }
}
