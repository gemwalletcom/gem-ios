// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemChartCandleStick {
    public func map() -> ChartCandleStick {
        ChartCandleStick(
            date: Date(timeIntervalSince1970: TimeInterval(date)),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}

extension GemChartCandleUpdate {
    public func map() -> ChartCandleUpdate {
        ChartCandleUpdate(
            coin: coin,
            interval: interval,
            candle: candle.map()
        )
    }
}