// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ChartSelection {
    let period: ChartPeriod
    let title: String
}

extension ChartSelection: Identifiable {
    var id: String { period.rawValue }
}
