// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import BigInt

public enum AmountType: Equatable, Hashable, Sendable {
    case transfer(recipient: RecipientData)
    case deposit(recipient: RecipientData)
    case withdraw(recipient: RecipientData)
    case stake(validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case stakeUnstake(delegation: Delegation)
    case stakeRedelegate(delegation: Delegation, validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case stakeWithdraw(delegation: Delegation)
    case freeze(data: FreezeData)
    case perpetual(PerpetualRecipientData)
    case earn(action: YieldType, data: YieldData, depositedBalance: BigInt?)
}
