// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Localization
import Perpetuals
import Primitives
import PrimitivesComponents
import Staking
import Validators

struct TransferDataBuilder {
    private let input: AmountInput
    private let balanceViewModel: AmountBalanceViewModel
    private let validatorViewModel: AmountValidatorViewModel
    private let resourceViewModel: AmountResourceViewModel
    private let perpetualViewModel: AmountPerpetualViewModel

    init(
        input: AmountInput,
        balanceViewModel: AmountBalanceViewModel,
        validatorViewModel: AmountValidatorViewModel,
        resourceViewModel: AmountResourceViewModel,
        perpetualViewModel: AmountPerpetualViewModel
    ) {
        self.input = input
        self.balanceViewModel = balanceViewModel
        self.validatorViewModel = validatorViewModel
        self.resourceViewModel = resourceViewModel
        self.perpetualViewModel = perpetualViewModel
    }

    private var type: AmountType { input.type }
    private var asset: Asset { input.asset }
    private var validator: DelegationValidator? { validatorViewModel.currentValidator }

    func build(value: BigInt) throws -> TransferData {
        TransferData(
            type: try transferDataType(value: value),
            recipientData: recipientData,
            value: value,
            canChangeValue: balanceViewModel.canChangeValue
        )
    }
}

// MARK: - Private

extension TransferDataBuilder {
    private var recipientData: RecipientData {
        switch type {
        case .transfer(let recipient): recipient
        case .deposit(let recipient): recipient
        case .withdraw(let recipient): recipient
        case .perpetual(let data): data.recipient
        case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: RecipientData(
            recipient: validatorViewModel.stakingRecipient(chain: asset.chain),
            amount: .none
        )
        case .freeze: RecipientData(
            recipient: resourceViewModel.freezeRecipient,
            amount: .none
        )
        }
    }

    private func transferDataType(value: BigInt) throws -> TransferDataType {
        switch type {
        case .transfer:
            return .transfer(asset)
        case .deposit:
            return .deposit(asset)
        case .withdraw:
            return .withdrawal(asset)
        case .perpetual(let data):
            let order = try perpetualViewModel.perpetualOrder(value: value, assetDecimals: asset.decimals.asInt)
            return .perpetual(data.positionAction.transferData.asset, order)
        case .stake:
            guard let validator else { throw TransferError.invalidAmount }
            return .stake(asset, .stake(validator))
        case .stakeUnstake(let delegation):
            return .stake(asset, .unstake(delegation))
        case .stakeRedelegate(let delegation, _, _):
            guard let validator else { throw TransferError.invalidAmount }
            return .stake(asset, .redelegate(RedelegateData(delegation: delegation, toValidator: validator)))
        case .stakeWithdraw(let delegation):
            return .stake(asset, .withdraw(delegation))
        case .freeze(let data):
            return .stake(asset, .freeze(data))
        }
    }
}
