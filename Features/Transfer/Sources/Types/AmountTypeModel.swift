// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Formatters
import Primitives

public enum AmountTypeModel {
    case none
    case staking(StakingAmountTypeViewModel)
    case perpetual(PerpetualAmountTypeViewModel)
    case freeze(FreezeAmountTypeViewModel)

    public static func from(
        type: AmountType,
        currencyFormatter: CurrencyFormatter
    ) -> AmountTypeModel {
        switch type {
        case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: .staking(StakingAmountTypeViewModel(amountType: type))
        case .perpetual(let data): .perpetual(PerpetualAmountTypeViewModel(
            positionAction: data.positionAction,
            currencyFormatter: currencyFormatter
        ))
        case .freeze(let data): .freeze(FreezeAmountTypeViewModel(freezeData: data))
        case .transfer, .deposit, .withdraw: .none
        }
    }

    public var staking: StakingAmountTypeViewModel? {
        if case .staking(let model) = self { return model }
        return nil
    }

    public var perpetual: PerpetualAmountTypeViewModel? {
        if case .perpetual(let model) = self { return model }
        return nil
    }

    public var freeze: FreezeAmountTypeViewModel? {
        if case .freeze(let model) = self { return model }
        return nil
    }
}
