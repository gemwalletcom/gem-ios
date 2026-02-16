// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension TotalFiatValue {
    static func mock(
        value: Double = 1000,
        pnlAmount: Double = 50,
        pnlPercentage: Double = 5
    ) -> TotalFiatValue {
        TotalFiatValue(value: value, pnlAmount: pnlAmount, pnlPercentage: pnlPercentage)
    }
}
