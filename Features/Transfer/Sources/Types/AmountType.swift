// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum AmountType: Equatable, Hashable, Sendable {
    case transfer(recipient: RecipientData)
    case stake(validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case unstake(delegation: Delegation)
    case redelegate(delegation: Delegation, validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case withdraw(delegation: Delegation)
}
