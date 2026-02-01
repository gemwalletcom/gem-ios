// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemChartCandleStick {
    public func map() throws -> ChartCandleStick {
        ChartCandleStick(
            date: Date(timeIntervalSince1970: TimeInterval(date)),
            interval: interval,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}