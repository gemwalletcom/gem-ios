// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Staking

@Observable
public final class StakingAmountTypeViewModel: AmountTypeConfigurable {
    public typealias Item = DelegationValidator
    public typealias ItemViewModel = StakeValidatorViewModel

    private let amountType: AmountType

    public var selectedItem: DelegationValidator?

    public init(amountType: AmountType) {
        self.amountType = amountType
        self.selectedItem = defaultItem
    }

    public var items: [DelegationValidator] {
        switch amountType {
        case .stake(let validators, _): validators
        case .stakeUnstake(let delegation): [delegation.validator]
        case .stakeRedelegate(_, let validators, _): validators
        case .stakeWithdraw(let delegation): [delegation.validator]
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: []
        }
    }

    public var defaultItem: DelegationValidator? {
        switch amountType {
        case .stake(_, let recommended): recommended ?? items.first
        case .stakeRedelegate(_, _, let recommended): recommended ?? items.first
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeWithdraw, .freeze: items.first
        }
    }

    public var selectedItemViewModel: StakeValidatorViewModel? {
        selectedItem.map { StakeValidatorViewModel(validator: $0) }
    }

    public var isSelectionEnabled: Bool {
        switch amountType {
        case .stake, .stakeRedelegate: true
        case .stakeUnstake, .stakeWithdraw: false
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: false
        }
    }

    public var selectionTitle: String { Localized.Stake.validator }

    public var stakeValidatorsType: StakeValidatorsType {
        switch amountType {
        case .stakeUnstake, .stakeWithdraw: .unstake
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate, .freeze: .stake
        }
    }

    public var delegations: [Delegation] {
        switch amountType {
        case .stakeUnstake(let delegation): [delegation]
        case .stakeRedelegate(let delegation, _, _): [delegation]
        case .stakeWithdraw(let delegation): [delegation]
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .freeze: []
        }
    }
}
