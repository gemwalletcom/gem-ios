// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemChartDateValue {
    public func map() -> ChartDateValue {
        ChartDateValue(
            date: Date(timeIntervalSince1970: TimeInterval(date)),
            value: value
        )
    }
}
