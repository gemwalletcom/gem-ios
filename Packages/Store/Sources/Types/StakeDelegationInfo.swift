// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct StakeDelegationInfo: Codable, FetchableRecord {
    let position: StakeDelegationRecord
    let validator: StakeValidatorRecord?
    let price: PriceRecord?
}

extension StakeDelegationInfo {
    func mapToDelegation() -> Delegation? {
        guard let validator else {
            return nil
        }

        return Delegation(
            base: DelegationBase(
                assetId: position.assetId,
                state: position.state,
                balance: position.balance,
                shares: position.shares ?? "0",
                rewards: position.rewards,
                completionDate: position.completionDate,
                delegationId: position.delegationId,
                validatorId: validator.validatorId
            ),
            validator: validator.validator,
            price: price?.mapToPrice()
        )
    }
}
