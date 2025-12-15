// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Rewards {
    static func mock(
        code: String? = "test123",
        referralCount: Int32 = 5,
        points: Int32 = 0,
        usedReferralCode: String? = nil
    ) -> Rewards {
        Rewards(
            code: code,
            referralCount: referralCount,
            points: points,
            usedReferralCode: usedReferralCode
        )
    }
}

public extension RewardsEventItem {
    static func mock(
        event: RewardsEvent = .invite,
        points: Int32 = 100,
        createdAt: Date = Date()
    ) -> RewardsEventItem {
        RewardsEventItem(event: event, points: points, createdAt: createdAt)
    }
}
