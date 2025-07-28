// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension DelegationBase {
    static func mock(
        assetId: AssetId = .mock(),
        state: DelegationState
    ) -> DelegationBase {
        DelegationBase(
            assetId: assetId,
            state: state,
            balance: .empty,
            shares: .empty,
            rewards: .empty,
            completionDate: nil,
            delegationId: .empty,
            validatorId: .empty
        )
    }
}
