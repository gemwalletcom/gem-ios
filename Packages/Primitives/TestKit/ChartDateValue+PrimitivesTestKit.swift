// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ChartDateValue {
    static func mock(
        date: Date = Date(),
        value: Double = 100.0
    ) -> ChartDateValue {
        ChartDateValue(date: date, value: value)
    }

    static func mockHistory(
        startDate: Date = Date().addingTimeInterval(-86400),
        values: [Double] = [100, 105, 102, 108, 110]
    ) -> [ChartDateValue] {
        let interval = 86400.0 / Double(values.count)
        return values.enumerated().map { index, value in
            ChartDateValue(
                date: startDate.addingTimeInterval(Double(index) * interval),
                value: value
            )
        }
    }
}
