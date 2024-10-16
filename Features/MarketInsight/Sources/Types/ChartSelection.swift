// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ChartSelection {
    public let period: ChartPeriod
    public let title: String

    public init(period: ChartPeriod, title: String) {
        self.period = period
        self.title = title
    }
}

extension ChartSelection: Identifiable {
    public var id: String { period.rawValue }
}
