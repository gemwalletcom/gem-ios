// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension DelegationBase {
    static func mock(
        state: DelegationState
    ) -> DelegationBase {
        DelegationBase(
            assetId: .mock(),
            state: state,
            balance: "1",
            shares: .empty,
            rewards: .empty,
            completionDate: nil,
            delegationId: .empty,
            validatorId: .empty
        )
    }
}
