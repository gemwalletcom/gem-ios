// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension BannerEvent: Comparable {
    public static func < (lhs: BannerEvent, rhs: BannerEvent) -> Bool {
        lhs.sortPriority < rhs.sortPriority
    }
    
    private var sortPriority: Int {
        switch self {
        case .accountBlockedMultiSignature: 0
        case .accountActivation: 1
        case .activateAsset: 2
        case .suspiciousAsset: 3
        case .onboarding: 4
        case .enableNotifications: 5
        case .stake: 6
        }
    }
}
