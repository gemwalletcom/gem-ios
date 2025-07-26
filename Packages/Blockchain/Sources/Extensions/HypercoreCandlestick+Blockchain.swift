// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension HypercoreCandlestick {
    public func toCandlestick() -> ChartCandleStick? {
        guard
            let open = Double(o),
            let high = Double(h),
            let low = Double(l),
            let close = Double(c),
            let volume = Double(v)
        else { return nil }
        
        let date = Date(timeIntervalSince1970: TimeInterval(t) / 1000)
        
        return ChartCandleStick(
            date: date,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
