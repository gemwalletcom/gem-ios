// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension DelegationBase {
    static func mock(
        state: DelegationState,
        assetId: AssetId = .mock(),
        balance: String = .empty,
        shares: String = .empty,
        rewards: String = .empty,
        completionDate: Date? = nil,
        delegationId: String = .empty,
        validatorId: String = .empty
    ) -> DelegationBase {
        DelegationBase(
            assetId: assetId,
            state: state,
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: completionDate,
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}
