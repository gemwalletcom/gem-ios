// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemStakeType {
    public func map() throws -> StakeType {
        switch self {
        case .delegate(let validator):
            return .stake(try validator.map())
        case .undelegate(let delegation):
            return .unstake(try delegation.map())
        case .redelegate(let delegation, let toValidator):
            return .redelegate(RedelegateData(delegation: try delegation.map(), toValidator: try toValidator.map()))
        case .withdrawRewards(let validators):
            let mappedValidators = try validators.map { try $0.map() }
            return .rewards(mappedValidators)
        case .withdraw(let delegation):
            return .withdraw(try delegation.map())
        }
    }
}

extension StakeType {
    public func map() -> GemStakeType {
        switch self {
        case .stake(let validator):
            return .delegate(validator: validator.map())
        case .unstake(let delegation):
            return .undelegate(delegation: delegation.map())
        case .redelegate(let data):
            return .redelegate(delegation: data.delegation.map(), toValidator: data.toValidator.map())
        case .rewards(let validators):
            return .withdrawRewards(validators: validators.map { $0.map() })
        case .withdraw(let delegation):
            return .withdraw(delegation: delegation.map())
        }
    }
}
