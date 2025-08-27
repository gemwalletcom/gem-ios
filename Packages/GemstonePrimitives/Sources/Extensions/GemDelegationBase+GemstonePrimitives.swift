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

extension DelegationBase {
    public func map() -> GemDelegationBase {
        return GemDelegationBase(
            assetId: assetId.identifier,
            delegationId: delegationId,
            validatorId: validatorId,
            balance: balance,
            shares: shares,
            completionDate: completionDate.map { UInt64($0.timeIntervalSince1970) },
            delegationState: state.rawValue,
            rewards: rewards
        )
    }
}
