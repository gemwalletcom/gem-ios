// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import BigInt

public enum StakeAmountType: Equatable, Hashable, Sendable {
    case stake(validators: [DelegationValidator], recommended: DelegationValidator?)
    case unstake(Delegation)
    case redelegate(Delegation, validators: [DelegationValidator], recommended: DelegationValidator?)
    case withdraw(Delegation)
}

public enum EarnAmountType: Equatable, Hashable, Sendable {
    case deposit(provider: DelegationValidator)
    case withdraw(delegation: Delegation)
}

public enum AmountType: Equatable, Hashable, Sendable {
    case transfer(recipient: RecipientData)
    case deposit(recipient: RecipientData)
    case withdraw(recipient: RecipientData)
    case stake(StakeAmountType)
    case freeze(data: FreezeData)
    case perpetual(PerpetualRecipientData)
    case earn(EarnAmountType)
}
