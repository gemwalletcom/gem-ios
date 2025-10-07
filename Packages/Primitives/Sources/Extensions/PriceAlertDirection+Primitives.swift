// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceAlertDirection: Comparable {
    public static func < (lhs: PriceAlertDirection, rhs: PriceAlertDirection) -> Bool {
        lhs.sortPriority < rhs.sortPriority
    }

    private var sortPriority: Int {
        switch self {
        case .down: 0
        case .up: 1
        }
    }
}
