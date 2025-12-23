// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import Localization
import Primitives
import Staking
import Validators

struct AmountValidatorViewModel {
    private let type: AmountType
    let currentValidator: DelegationValidator?

    init(type: AmountType, currentValidator: DelegationValidator?) {
        self.type = type
        self.currentValidator = currentValidator
    }

    func stakingRecipient(chain: Chain) -> Recipient {
        let address: String = if let id = currentValidator?.id, let stakeChain = chain.stakeChain {
            recipientAddress(chain: stakeChain, validatorId: id)
        } else {
            ""
        }
        return Recipient(
            name: currentValidator?.name,
            address: address,
            memo: Localized.Stake.viagem
        )
    }

    var validators: [DelegationValidator] {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: []
        case .stake(let validators, _): validators
        case .stakeUnstake(let delegation): [delegation.validator]
        case .stakeRedelegate(_, let validators, _): validators
        case .stakeWithdraw(let delegation): [delegation.validator]
        }
    }

    var stakeValidatorsType: StakeValidatorsType {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate: .stake
        case .stakeUnstake, .stakeWithdraw: .unstake
        case .freeze: fatalError("unsupported")
        }
    }

    var showValidator: Bool {
        switch type {
        case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: true
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: false
        }
    }

    var isSelectable: Bool {
        switch type {
        case .stake, .stakeRedelegate: true
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    static func defaultValidator(for type: AmountType) -> DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .stakeRedelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeWithdraw, .freeze: nil
        }
        let validators: [DelegationValidator] = switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: []
        case .stake(let validators, _): validators
        case .stakeUnstake(let delegation): [delegation.validator]
        case .stakeRedelegate(_, let validators, _): validators
        case .stakeWithdraw(let delegation): [delegation.validator]
        }
        return recommended ?? validators.first
    }
}

// MARK: - Private

extension AmountValidatorViewModel {
    private func recipientAddress(chain: StakeChain, validatorId: String) -> String {
        switch chain {
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui, .tron, .smartChain, .ethereum, .aptos, .monad:
            return validatorId
        case .hyperCore:
            return ""
        }
    }
}

// MARK: - ItemModelProvidable

extension AmountValidatorViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        guard showValidator, let currentValidator else { return .empty }
        return .validator(
            AmountValidatorItemModel(
                validator: StakeValidatorViewModel(validator: currentValidator),
                isSelectable: isSelectable
            )
        )
    }
}
