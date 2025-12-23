// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Gemstone
import GemstonePrimitives
import Localization
import Primitives
import PrimitivesComponents
import Staking

struct AmountBalanceViewModel {
    private let formatter = ValueFormatter(style: .full)

    private let type: AmountType
    private let asset: Asset
    private let balance: Balance

    init(type: AmountType, assetData: AssetData) {
        self.type = type
        self.asset = assetData.asset
        self.balance = assetData.balance
    }

    var showBalance: Bool { canChangeValue }
    var canChangeValue: Bool {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate, .freeze:
            return true
        case .stakeUnstake:
            if let chain = StakeChain(rawValue: asset.chain.rawValue) {
                return chain.canChangeAmountOnUnstake
            }
            return true
        case .stakeWithdraw:
            return false
        }
    }

    var availableValue: BigInt {
        switch type {
        case .transfer, .deposit:
            return balance.available
        case .perpetual(let perpetualData):
            switch perpetualData.positionAction {
            case .open, .increase: return balance.available
            case .reduce(_, let available, _): return available
            }
        case .stake:
            switch asset.chain {
            case .tron:
                let staked = BigNumberFormatter.standard.number(
                    from: Int(balance.metadata?.votes ?? 0),
                    decimals: Int(asset.decimals)
                )
                return (balance.frozen + balance.locked) - staked
            default:
                return balance.available
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze:
                return balance.available
            case .unfreeze:
                switch data.resource {
                case .bandwidth: return balance.frozen
                case .energy: return balance.locked
                }
            }
        case .withdraw:
            return balance.withdrawable
        case .stakeUnstake(let delegation):
            return delegation.base.balanceValue
        case .stakeRedelegate(let delegation, _, _):
            return delegation.base.balanceValue
        case .stakeWithdraw(let delegation):
            return delegation.base.balanceValue
        }
    }

    var balanceText: String {
        ValueFormatter(style: .medium).string(
            availableValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }

    var assetImage: AssetImage {
        AssetViewModel(asset: asset).assetImage
    }

    var maxBalanceText: String {
        formatter.string(maxValue, decimals: asset.decimals.asInt)
    }

    var reservedFeesText: String {
        formatter.string(reserveForFee, asset: asset)
    }

    var reserveForFee: BigInt {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: .zero
        case .stake:
            switch asset.chain {
            case .tron: .zero
            default: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
            case .unfreeze: .zero
            }
        }
    }

    var shouldReserveFee: Bool {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: false
        case .stake:
            switch asset.chain {
            case .tron: false
            default: availableBalanceForMaxStaking > minimumStakeAmount && !reserveForFee.isZero
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: availableBalanceForMaxStaking > minimumStakeAmount
            case .unfreeze: false
            }
        }
    }

    private var maxValue: BigInt {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw:
            availableValue
        case .stake:
            switch asset.chain {
            case .tron: availableValue
            default: shouldReserveFee ? availableBalanceForMaxStaking : availableValue
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: shouldReserveFee ? availableBalanceForMaxStaking : availableValue
            case .unfreeze: availableValue
            }
        }
    }

    private var availableBalanceForMaxStaking: BigInt {
        max(.zero, availableValue - reserveForFee)
    }

    var minimumStakeAmount: BigInt {
        guard let stakeChain = asset.chain.stakeChain else { return .zero }
        return BigInt(StakeConfig.config(chain: stakeChain).minAmount)
    }
}

// MARK: - ItemModelProvidable

extension AmountBalanceViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        guard showBalance else { return .empty }
        return .balance(
            AmountBalanceItemModel(
                assetImage: assetImage,
                assetName: asset.name,
                balanceText: balanceText,
                maxTitle: Localized.Transfer.max
            )
        )
    }
}
