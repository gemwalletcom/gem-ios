// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension AssetRank {
    var rank: Int {
        switch self {
        case .high: 100
        case .medium: 50
        case .low: 25
        case .trivial: 15
        case .unknown: 0
        case .inactive: -2
        case .abandoned: -5
        case .suspended: -8
        case .migrated: -10
        case .deprecated: -12
        case .spam: -15
        case .fradulent: -20
        }
    }
}
