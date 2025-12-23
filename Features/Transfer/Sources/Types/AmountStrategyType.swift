// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Primitives

enum AmountStrategyType: AmountStrategy {
    case transfer(AmountTransferStrategy)
    case stake(AmountStakeStrategy)
    case perpetual(AmountPerpetualStrategy)

    private var strategy: any AmountStrategy {
        switch self {
        case .transfer(let strategy): strategy
        case .stake(let strategy): strategy
        case .perpetual(let strategy): strategy
        }
    }

    var asset: Asset { strategy.asset }
    var title: String { strategy.title }
    var amountType: AmountType { strategy.amountType }
    var minimumValue: BigInt { strategy.minimumValue }
    var canChangeValue: Bool { strategy.canChangeValue }
    var reserveForFee: BigInt { strategy.reserveForFee }

    func availableValue(from assetData: AssetData) -> BigInt {
        strategy.availableValue(from: assetData)
    }

    func shouldReserveFee(from assetData: AssetData) -> Bool {
        strategy.shouldReserveFee(from: assetData)
    }

    func maxValue(from assetData: AssetData) -> BigInt {
        strategy.maxValue(from: assetData)
    }

    func recipientData() -> RecipientData {
        strategy.recipientData()
    }

    func makeTransferData(value: BigInt) throws -> TransferData {
        try strategy.makeTransferData(value: value)
    }
}
