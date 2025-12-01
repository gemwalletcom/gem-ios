// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct ChartLine: Identifiable, Sendable {
    let type: ChartLineType
    let price: Double

    var id: String { "\(type)_\(price)" }
}
