// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ChartCandleStick {
    static func mock(
        date: Date = Date(timeIntervalSince1970: 0),
        open: Double = 100,
        high: Double = 110,
        low: Double = 90,
        close: Double = 105,
        volume: Double = 1000
    ) -> ChartCandleStick {
        ChartCandleStick(
            date: date,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
