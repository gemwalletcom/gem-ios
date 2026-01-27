// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct EarnPositionInfo: Codable, FetchableRecord {
    public let position: EarnPositionRecord
    public let validator: StakeValidatorRecord?
    public let price: PriceRecord?
}

extension EarnPositionInfo {
    public func mapToDelegation() -> Delegation? {
        guard position.type == .stake,
              let validator = validator,
              let state = position.state else {
            return nil
        }
        return Delegation(
            base: DelegationBase(
                assetId: position.assetId,
                state: state,
                balance: position.balance,
                shares: position.shares ?? "0",
                rewards: position.rewards ?? "0",
                completionDate: position.completionDate,
                delegationId: position.delegationId ?? "",
                validatorId: validator.validatorId
            ),
            validator: validator.validator,
            price: price?.mapToPrice()
        )
    }

    public var earnPosition: EarnPosition {
        position.earnPosition
    }
}
