// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Validators

public typealias TransferAmountValidation = Result<TransferAmount, TransferAmountCalculatorError>

public struct TransferAmountCalculator {
    public init() {}

    public func validate(input: TransferAmountInput) -> TransferAmountValidation {
        do {
            return .success(try calculate(input: input))
        } catch {
            return .failure(error)
        }
    }

    public func validateNetworkFee(_ feeBalance: BigInt, feeAssetId: AssetId) throws(TransferAmountCalculatorError) {
        if [Chain.hyperCore].contains(feeAssetId.chain) {
            return
        }
        if feeBalance.isZero && feeAssetId.type == .native {
            throw TransferAmountCalculatorError.insufficientNetworkFee(feeAssetId.chain.asset, required: nil)
        }
    }

    func calculate(input: TransferAmountInput) throws(TransferAmountCalculatorError) -> TransferAmount {
        if input.assetBalance.available == 0 && !input.ignoreValueCheck {
            guard input.fee.isZero else {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }

        if input.ignoreValueCheck {
            if let error = insufficientNetworkFeeError(input) {
                throw error
            }

            return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
        }

        if input.availableValue < input.value  {
            throw TransferAmountCalculatorError.insufficientBalance(input.asset)
        }

        if let error = insufficientNetworkFeeError(input) {
            throw error
        }

        if !input.canChangeValue && input.asset == input.assetFee {
            if  input.availableValue < input.value + input.fee {
                throw TransferAmountCalculatorError.insufficientBalance(input.asset)
            }
        }

        // max value transfer
        if input.assetBalance.available == input.value {
            if input.asset == input.asset.feeAsset && input.canChangeValue  {
                let value = input.assetBalance.available - input.fee - input.asset.chain.minimumAccountBalance
                if let error = minimumAccountBalanceTooLowError(value: value, input: input) {
                    throw error
                }
                return TransferAmount(
                    value: value,
                    networkFee: input.fee,
                    useMaxAmount: true
                )
            }
            return TransferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }

        if let error = minimumAccountBalanceTooLowError(value: input.availableValue - input.value - input.fee, input: input) {
            throw error
        }

        return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: input.availableValue == input.value)
    }
    
    private func insufficientNetworkFeeError(_ input: TransferAmountInput) -> TransferAmountCalculatorError? {
        if input.assetFeeBalance.available < input.fee {
            return TransferAmountCalculatorError.insufficientNetworkFee(input.assetFee, required: input.fee)
        }
        return nil
    }
    
    private func minimumAccountBalanceTooLowError(value: BigInt, input: TransferAmountInput) -> TransferAmountCalculatorError? {
        if input.asset.type == .native && input.asset.chain.minimumAccountBalance > 0 &&
            (value.isBetween(1, and: input.asset.chain.minimumAccountBalance) || value < 0)
        {
            return TransferAmountCalculatorError.minimumAccountBalanceTooLow(input.asset, required: input.asset.chain.minimumAccountBalance)
        }
        return nil
    }
}
