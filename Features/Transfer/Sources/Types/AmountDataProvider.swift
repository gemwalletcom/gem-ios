// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Primitives

enum AmountDataProvider: AmountDataProvidable {
    case transfer(AmountTransferViewModel)
    case stake(AmountStakeViewModel)
    case freeze(AmountFreezeViewModel)
    case perpetual(AmountPerpetualViewModel)

    static func make(from input: AmountInput) -> AmountDataProvider {
        switch input.type {
        case .transfer(let recipient):
            .transfer(AmountTransferViewModel(asset: input.asset, action: .send(recipient)))
        case .deposit(let recipient):
            .transfer(AmountTransferViewModel(asset: input.asset, action: .deposit(recipient)))
        case .withdraw(let recipient):
            .transfer(AmountTransferViewModel(asset: input.asset, action: .withdraw(recipient)))
        case .stake(let validators, let recommended):
            .stake(AmountStakeViewModel(asset: input.asset, action: .stake(validators: validators, recommended: recommended)))
        case .stakeUnstake(let delegation):
            .stake(AmountStakeViewModel(asset: input.asset, action: .unstake(delegation)))
        case .stakeRedelegate(let delegation, let validators, let recommended):
            .stake(AmountStakeViewModel(asset: input.asset, action: .redelegate(delegation, validators: validators, recommended: recommended)))
        case .stakeWithdraw(let delegation):
            .stake(AmountStakeViewModel(asset: input.asset, action: .withdraw(delegation)))
        case .freeze(let data):
            .freeze(AmountFreezeViewModel(asset: input.asset, data: data))
        case .perpetual(let data):
            .perpetual(AmountPerpetualViewModel(asset: input.asset, data: data))
        }
    }

    var asset: Asset { provider.asset }
    var title: String { provider.title }
    var amountType: AmountType { provider.amountType }
    var minimumValue: BigInt { provider.minimumValue }
    var canChangeValue: Bool { provider.canChangeValue }
    var reserveForFee: BigInt { provider.reserveForFee }

    func availableValue(from assetData: AssetData) -> BigInt {
        provider.availableValue(from: assetData)
    }

    func shouldReserveFee(from assetData: AssetData) -> Bool {
        provider.shouldReserveFee(from: assetData)
    }

    func maxValue(from assetData: AssetData) -> BigInt {
        provider.maxValue(from: assetData)
    }

    func recipientData() -> RecipientData {
        provider.recipientData()
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        try provider.makeTransferData(value: value)
    }
}

// MARK: - Private

extension AmountDataProvider {
    private var provider: any AmountDataProvidable {
        switch self {
        case .transfer(let provider): provider
        case .stake(let provider): provider
        case .freeze(let provider): provider
        case .perpetual(let provider): provider
        }
    }
}
