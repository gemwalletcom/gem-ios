// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Validators

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
            if  input.availableValue < input.value + input.fee {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }
        
        // max value transfer
        if input.assetBalance.available == input.value {
            if input.asset == input.asset.feeAsset && input.canChangeValue  {
                return TransferAmount(
                    value: input.assetBalance.available - input.fee,
                    networkFee: input.fee,
                    useMaxAmount: true
                )
            }
            return TransferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }
        if input.asset.type == .native && input.asset.chain.minimumAccountBalance > 0 &&
            (input.availableValue - input.value - input.fee).isBetween(1, and: input.asset.chain.minimumAccountBalance)
        {
            throw TransferAmountCalculatorError.minimumAccountBalanceTooLow(input.asset, required: input.asset.chain.minimumAccountBalance)
        }
        
        let useMaxAmount = input.availableValue == input.value
        
        return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: useMaxAmount)
    }
}
