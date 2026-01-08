// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ReferralQuota {
    static func mock(
        limit: Int32 = 10,
        available: Int32 = 5
    ) -> ReferralQuota {
        ReferralQuota(limit: limit, available: available)
    }
}

public extension ReferralAllowance {
    static func mock(
        daily: ReferralQuota = .mock(),
        weekly: ReferralQuota = .mock()
    ) -> ReferralAllowance {
        ReferralAllowance(daily: daily, weekly: weekly)
    }
}

public extension Rewards {
    static func mock(
        code: String? = "test123",
        referralCount: Int32 = 5,
        points: Int32 = 0,
        usedReferralCode: String? = nil,
        isEnabled: Bool = true,
        verified: Bool = true,
        redemptionOptions: [RewardRedemptionOption] = [],
        disableReason: String? = nil,
        referralAllowance: ReferralAllowance = .mock(),
        pendingVerificationAfter: Date? = nil
    ) -> Rewards {
        Rewards(
            code: code,
            referralCount: referralCount,
            points: points,
            usedReferralCode: usedReferralCode,
            isEnabled: isEnabled,
            verified: verified,
            redemptionOptions: redemptionOptions,
            disableReason: disableReason,
            referralAllowance: referralAllowance,
            pendingVerificationAfter: pendingVerificationAfter
        )
    }
}
