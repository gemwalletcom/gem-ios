// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ChartValues {
    static func mock(
        values: [Double] = [100, 150, 80, 120]
    ) -> ChartValues {
        let charts = values.enumerated().map {
            ChartDateValue(date: Date(timeIntervalSince1970: Double($0.offset) * 3600), value: $0.element)
        }
        return try! ChartValues.from(charts: charts)
    }
}
