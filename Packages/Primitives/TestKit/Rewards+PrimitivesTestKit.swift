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

public extension ReferralCodeActivation {
    static func mock(
        swapCompleted: Bool = false,
        swapAmount: Int32 = 0
    ) -> ReferralCodeActivation {
        ReferralCodeActivation(swapCompleted: swapCompleted, swapAmount: swapAmount)
    }
}

public extension ReferralActivation {
    static func mock(
        verifyCompleted: Bool = false,
        verifyAfter: Date? = nil,
        swapCompleted: Bool = false,
        swapAmount: Int32 = 0
    ) -> ReferralActivation {
        ReferralActivation(verifyCompleted: verifyCompleted, verifyAfter: verifyAfter, swapCompleted: swapCompleted, swapAmount: swapAmount)
    }
}

public extension Rewards {
    static func mock(
        code: String? = "test123",
        referralCount: Int32 = 5,
        points: Int32 = 0,
        usedReferralCode: String? = nil,
        status: RewardStatus = .verified,
        redemptionOptions: [RewardRedemptionOption] = [],
        disableReason: String? = nil,
        referralAllowance: ReferralAllowance = .mock(),
        referralCodeActivation: ReferralCodeActivation? = nil,
        referralActivation: ReferralActivation? = nil
    ) -> Rewards {
        Rewards(
            code: code,
            referralCount: referralCount,
            points: points,
            usedReferralCode: usedReferralCode,
            status: status,
            redemptionOptions: redemptionOptions,
            disableReason: disableReason,
            referralAllowance: referralAllowance,
            referralCodeActivation: referralCodeActivation,
            referralActivation: referralActivation
        )
    }
}
