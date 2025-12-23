// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AmountStrategyFactory {
    static func make(from input: AmountInput) -> AmountStrategyType {
        switch input.type {
        case .transfer(let recipient):
            .transfer(AmountTransferStrategy(asset: input.asset, action: .send(recipient)))
        case .deposit(let recipient):
            .transfer(AmountTransferStrategy(asset: input.asset, action: .deposit(recipient)))
        case .withdraw(let recipient):
            .transfer(AmountTransferStrategy(asset: input.asset, action: .withdraw(recipient)))
        case .stake(let validators, let recommended):
            .stake(AmountStakeStrategy(
                asset: input.asset,
                action: .stake(validators: validators, recommended: recommended)
            ))
        case .stakeUnstake(let delegation):
            .stake(AmountStakeStrategy(asset: input.asset, action: .unstake(delegation)))
        case .stakeRedelegate(let delegation, let validators, let recommended):
            .stake(AmountStakeStrategy(
                asset: input.asset,
                action: .redelegate(delegation, validators: validators, recommended: recommended)
            ))
        case .stakeWithdraw(let delegation):
            .stake(AmountStakeStrategy(asset: input.asset, action: .withdraw(delegation)))
        case .freeze(let data):
            .stake(AmountStakeStrategy(asset: input.asset, action: .freeze(data)))
        case .perpetual(let data):
            .perpetual(AmountPerpetualStrategy(asset: input.asset, data: data))
        }
    }
}
