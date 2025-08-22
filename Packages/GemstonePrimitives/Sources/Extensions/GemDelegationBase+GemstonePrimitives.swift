// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemDelegationBase {
    public func map() throws -> DelegationBase {
        DelegationBase(
            assetId: try AssetId(id: assetId),
            state: try DelegationState(id: delegationState),
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: completionDate.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}