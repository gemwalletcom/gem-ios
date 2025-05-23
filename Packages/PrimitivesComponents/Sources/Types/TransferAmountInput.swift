// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public enum TransferAmountResult {
    case amount(TransferAmount)
    case error(TransferAmount?, Error)
}

public struct TransferAmountInput {
    public let asset: Asset
    public let assetBalance: Balance
    public let value: BigInt
    public let availableValue: BigInt // maximum available value (unstake)

    public let assetFee: Asset
    public let assetFeeBalance: Balance
    public let fee: BigInt
    public let canChangeValue: Bool
    public let ignoreValueCheck: Bool // in some cases like claim rewards we should ignore checking total balance

    public init(
        asset: Asset,
        assetBalance: Balance,
        value: BigInt,
        availableValue: BigInt,
        assetFee: Asset,
        assetFeeBalance: Balance,
        fee: BigInt,
        canChangeValue: Bool,
        ignoreValueCheck: Bool = false
    ) {
        self.asset = asset
        self.assetBalance = assetBalance
        self.value = value
        self.availableValue = availableValue
        self.assetFee = assetFee
        self.assetFeeBalance = assetFeeBalance
        self.fee = fee
        self.canChangeValue = canChangeValue
        self.ignoreValueCheck = ignoreValueCheck
    }
    
    public var isMaxValue: Bool {
        value == availableValue
    }
}
