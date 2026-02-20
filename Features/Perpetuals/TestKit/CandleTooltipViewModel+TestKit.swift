// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
@testable import Perpetuals

public extension CandleTooltipViewModel {
    static func mock(
        candle: ChartCandleStick = .mock(),
        formatter: CurrencyFormatter = CurrencyFormatter(type: .currency, locale: Locale(identifier: "en_US"), currencyCode: "USD")
    ) -> CandleTooltipViewModel {
        CandleTooltipViewModel(candle: candle, formatter: formatter)
    }
}
