// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Formatters
import Foundation
import Gemstone
import GemstonePrimitives
import Localization
import Primitives
import PrimitivesComponents
import Staking
import Validators

enum StakeAction {
    case stake(validators: [DelegationValidator], recommended: DelegationValidator?)
    case unstake(Delegation)
    case redelegate(Delegation, validators: [DelegationValidator], recommended: DelegationValidator?)
    case withdraw(Delegation)
    case freeze(FreezeData)

    var freezeData: FreezeData? {
        if case .freeze(let data) = self {
            data
        } else {
            nil
        }
    }
}

final class AmountStakeStrategy: AmountStrategy {
    let asset: Asset
    let action: StakeAction
    let validatorSelection: ValidatorSelection
    let resourceSelection: ResourceSelection?

    init(asset: Asset, action: StakeAction) {
        self.asset = asset
        self.action = action
        self.validatorSelection = Self.makeValidatorSelection(action: action)
        self.resourceSelection = action.freezeData.map { ResourceSelection(selected: $0.resource) }
    }

    private static func makeValidatorSelection(action: StakeAction) -> ValidatorSelection {
        switch action {
        case .stake(let validators, let recommended):
            ValidatorSelection(options: validators, recommended: recommended, isPickerEnabled: true, type: .stake)
        case .unstake(let delegation):
            ValidatorSelection(options: [delegation.validator], recommended: delegation.validator, isPickerEnabled: false, type: .unstake)
        case .redelegate(_, let validators, let recommended):
            ValidatorSelection(options: validators, recommended: recommended, isPickerEnabled: true, type: .stake)
        case .withdraw(let delegation):
            ValidatorSelection(options: [delegation.validator], recommended: delegation.validator, isPickerEnabled: false, type: .unstake)
        case .freeze:
            ValidatorSelection(options: [], recommended: nil, isPickerEnabled: false, type: .stake)
        }
    }

    var validatorSectionTitle: String { Localized.Stake.validator }

    var title: String {
        switch action {
        case .stake: Localized.Transfer.Stake.title
        case .unstake: Localized.Transfer.Unstake.title
        case .redelegate: Localized.Transfer.Redelegate.title
        case .withdraw: Localized.Transfer.Withdraw.title
        case .freeze(let data):
            data.freezeType == .freeze ? Localized.Transfer.Freeze.title : Localized.Transfer.Unfreeze.title
        }
    }

    var amountType: AmountType {
        switch action {
        case .stake(let validators, let recommended):
            .stake(validators: validators, recommendedValidator: recommended)
        case .unstake(let delegation):
            .stakeUnstake(delegation: delegation)
        case .redelegate(let delegation, let validators, let recommended):
            .stakeRedelegate(delegation: delegation, validators: validators, recommendedValidator: recommended)
        case .withdraw(let delegation):
            .stakeWithdraw(delegation: delegation)
        case .freeze(let data):
            .freeze(data: data)
        }
    }

    var minimumValue: BigInt {
        guard let stakeChain = asset.chain.stakeChain else { return .zero }
        return switch action {
        case .stake:
            BigInt(StakeConfig.config(chain: stakeChain).minAmount)
        case .redelegate:
            stakeChain == .smartChain ? BigInt(StakeConfig.config(chain: stakeChain).minAmount) : .zero
        case .freeze(let data):
            data.freezeType == .freeze ? BigInt(StakeConfig.config(chain: stakeChain).minAmount) : .zero
        case .unstake:
            .zero
        case .withdraw:
            asset.symbol == "USDC" ? BigInt(5_000_000) : .zero
        }
    }

    var canChangeValue: Bool {
        switch action {
        case .stake, .redelegate, .freeze:
            true
        case .unstake:
            StakeChain(rawValue: asset.chain.rawValue)?.canChangeAmountOnUnstake ?? true
        case .withdraw:
            false
        }
    }

    func shouldReserveFee(from assetData: AssetData) -> Bool {
        let maxAfterFee = max(.zero, availableValue(from: assetData) - reserveForFee)
        return switch action {
        case .stake:
            asset.chain != .tron && maxAfterFee > minimumValue && !reserveForFee.isZero
        case .freeze(let data):
            data.freezeType == .freeze && maxAfterFee > minimumValue
        case .unstake, .redelegate, .withdraw:
            false
        }
    }

    var reserveForFee: BigInt {
        switch action {
        case .stake where asset.chain != .tron:
            BigInt(Gemstone.Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
        case .freeze(let data) where data.freezeType == .freeze:
            BigInt(Gemstone.Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
        default:
            .zero
        }
    }

    func availableValue(from assetData: AssetData) -> BigInt {
        switch action {
        case .stake:
            if asset.chain == .tron {
                let staked = BigNumberFormatter.standard.number(
                    from: Int(assetData.balance.metadata?.votes ?? 0),
                    decimals: Int(assetData.asset.decimals)
                )
                return (assetData.balance.frozen + assetData.balance.locked) - staked
            }
            return assetData.balance.available
        case .unstake(let delegation), .redelegate(let delegation, _, _), .withdraw(let delegation):
            return delegation.base.balanceValue
        case .freeze(let data):
            switch data.freezeType {
            case .freeze:
                return assetData.balance.available
            case .unfreeze:
                let resource = resourceSelection?.selected ?? data.resource
                return resource == .bandwidth ? assetData.balance.frozen : assetData.balance.locked
            }
        }
    }

    func recipientData() -> RecipientData {
        switch action {
        case .stake, .unstake, .redelegate, .withdraw:
            return RecipientData(
                recipient: Recipient(
                    name: validatorSelection.selected?.name,
                    address: validatorSelection.selected.map { recipientAddress(validatorId: $0.id) } ?? "",
                    memo: Localized.Stake.viagem
                ),
                amount: nil
            )
        case .freeze:
            let resource = resourceSelection?.selected ?? .bandwidth
            let title = ResourceViewModel(resource: resource).title
            return RecipientData(
                recipient: Recipient(name: title, address: title, memo: nil),
                amount: nil
            )
        }
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        let stakeType: StakeType
        switch action {
        case .stake:
            guard let validator = validatorSelection.selected else { throw TransferError.invalidAmount }
            stakeType = .stake(validator)
        case .unstake(let delegation):
            stakeType = .unstake(delegation)
        case .redelegate(let delegation, _, _):
            guard let validator = validatorSelection.selected else { throw TransferError.invalidAmount }
            stakeType = .redelegate(RedelegateData(delegation: delegation, toValidator: validator))
        case .withdraw(let delegation):
            stakeType = .withdraw(delegation)
        case .freeze(let data):
            stakeType = .freeze(FreezeData(freezeType: data.freezeType, resource: resourceSelection?.selected ?? data.resource))
        }
        return TransferData(
            type: .stake(asset, stakeType),
            recipientData: recipientData(),
            value: value,
            canChangeValue: canChangeValue
        )
    }

    private func recipientAddress(validatorId: String) -> String {
        switch asset.chain.stakeChain {
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui, .tron, .smartChain, .ethereum, .aptos, .monad:
            validatorId
        case .none, .hyperCore:
            ""
        }
    }
}
