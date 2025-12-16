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
            usedReferralCode: usedReferralCode,
            isEnabled: true
        )
    }
}

public extension RewardEvent {
    static func mock(
        event: RewardEventType = .inviteNew,
        points: Int32 = 100,
        createdAt: Date = Date()
    ) -> RewardEvent {
        RewardEvent(event: event, points: points, createdAt: createdAt)
    }
}
