// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import GemstonePrimitives

public enum TransferAmountResult {
    case amount(TransferAmount)
    case error(TransferAmount, Error)
    
    public var isValid: Bool {
        switch self {
        case .amount: true
        case .error: false
        }
    }
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

public struct TransferAmountCalculator {
    public init() {}

    public func calculateResult(input: TransferAmountInput) -> TransferAmountResult {
        do {
            let amount = try calculate(input: input)
            return .amount(amount)
        } catch let error as TransferAmountCalculatorError {
            let amount = TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
            return .error(amount, error)
        } catch {
            let amount = TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
            return .error(amount, error)
        }
    }

    public func calculate(input: TransferAmountInput) throws -> TransferAmount {
        if input.assetBalance.available == 0 && !input.ignoreValueCheck {
            guard input.fee.isZero else {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }

        //TODO: Check for input.value + input.fee

        if input.ignoreValueCheck {

            if input.assetFeeBalance.available < input.fee {
                throw TransferAmountCalculatorError.insufficientNetworkFee(input.assetFee)
            }

            return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
        }

        if input.availableValue < input.value  {
            throw TransferAmountCalculatorError.insufficientBalance(input.asset)
        }
        
        if input.assetFeeBalance.available < input.fee {
            throw TransferAmountCalculatorError.insufficientNetworkFee(input.assetFee)
        }

        if !input.canChangeValue && input.asset == input.assetFee {
            if  input.availableValue < input.value + input.fee   {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }

        // max value transfer
        if input.assetBalance.available == input.value {
            if input.asset == input.asset.feeAsset && input.canChangeValue  {
                return TransferAmount(value: input.assetBalance.available - input.fee, networkFee: input.fee, useMaxAmount: true)
            }
            return TransferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }
        let useMaxAmount = input.availableValue == input.value

        return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: useMaxAmount)
    }
}
