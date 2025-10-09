// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension BannerState: Comparable {
    public static func < (lhs: BannerState, rhs: BannerState) -> Bool {
        lhs.sortPriority < rhs.sortPriority
    }
    
    private var sortPriority: Int {
        switch self {
        case .alwaysActive: 0
        case .active: 1
        case .cancelled: 2
        }
    }
}