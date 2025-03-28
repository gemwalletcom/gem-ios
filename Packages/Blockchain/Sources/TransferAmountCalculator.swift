// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

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

        //TODO: Check for input.value + input.fee + minimumAccountBalance

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
            if  input.availableValue < input.value + input.fee + BigInt(input.asset.chain.minimumAccountBalance ?? 0) {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }

        // max value transfer
        if input.assetBalance.available == input.value {
            if input.asset == input.asset.feeAsset && input.canChangeValue  {
                return TransferAmount(
                    value: input.assetBalance.available - input.fee - BigInt(input.asset.chain.minimumAccountBalance ?? 0),
                    networkFee: input.fee,
                    useMaxAmount: true
                )
            }
            return TransferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }
        let useMaxAmount = input.availableValue == input.value

        return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: useMaxAmount)
    }

    public func validateBalance(
        asset: Asset,
        assetBalance: Balance,
        value: BigInt,
        availableValue: BigInt,
        ignoreValueCheck: Bool = false,
        canChangeValue: Bool
    ) throws {
        if !canChangeValue {
            return
        }
        if !ignoreValueCheck, assetBalance.available == 0 || availableValue < value {
            throw TransferAmountCalculatorError.insufficientBalance(asset)
        }
    }
}
