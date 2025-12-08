// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Primitives
@testable import PrimitivesComponents

public extension AmountDisplayStyle {
    static func mock(
        sign: AmountDisplaySign = .none,
        formatter: ValueFormatter = .full,
        currencyCode: String = "USD"
    ) -> AmountDisplayStyle {
        AmountDisplayStyle(
            sign: sign,
            formatter: formatter,
            currencyCode: currencyCode
        )
    }
}