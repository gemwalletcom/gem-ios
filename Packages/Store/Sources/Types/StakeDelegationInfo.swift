// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct StakeDelegationInfo: Codable, FetchableRecord {
    let delegation: StakeDelegationRecord
    let validator: StakeValidatorRecord
    let price: PriceRecord?
}

extension StakeDelegationInfo {
    func mapToDelegation() -> Delegation {
        return Delegation(
            base: DelegationBase(
                assetId: delegation.assetId,
                state: delegation.state,
                balance: delegation.balance,
                shares: delegation.shares ?? "0",
                rewards: delegation.rewards,
                completionDate: delegation.completionDate,
                delegationId: delegation.delegationId,
                validatorId: validator.validatorId
            ),
            validator: validator.validator,
            price: price?.mapToPrice()
        )
    }
}
