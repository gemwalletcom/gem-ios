// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum StakeType: Hashable, Equatable, Sendable {
    case stake(validator: DelegationValidator)
    case unstake(delegation: Delegation)
    case redelegate(delegation: Delegation, toValidator: DelegationValidator)
    case rewards(validators: [DelegationValidator])
    case withdraw(delegation: Delegation)
}

extension StakeType {
    public var validatorId: String {
        return switch self {
        case .stake(let validator):
            validator.id
        case .unstake(let delegation):
            delegation.validator.id
        case .redelegate(let delegation, _):
            delegation.validator.id
        case .rewards(let validators):
            validators.first?.id ?? ""
        case .withdraw(let delegation):
            delegation.validator.id
        }
    }
}
