// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import GemstonePrimitives

public enum TransferAmountResult {
    case amount(TransferAmount)
    case error(TransferAmount, Error)
}

public struct TranferAmountInput {
    public let asset: Asset
    public let assetBalance: Balance
    public let value: BigInt
    public let availableValue: BigInt // maximum available value (unstake)
    
    public let assetFee: Asset
    public let assetFeeBalance: Balance
    public let fee: BigInt
    
    public init(
        asset: Asset,
        assetBalance: Balance,
        value: BigInt,
        availableValue: BigInt,
        assetFee: Asset,
        assetFeeBalance: Balance,
        fee: BigInt
    ) {
        self.asset = asset
        self.assetBalance = assetBalance
        self.value = value
        self.availableValue = availableValue
        self.assetFee = assetFee
        self.assetFeeBalance = assetFeeBalance
        self.fee = fee
    }
    
    public var isMaxValue: Bool {
        value == availableValue
    }
}

public struct TransferAmountCalculator {
    public init() {}

    public func calculateResult(input: TranferAmountInput) -> TransferAmountResult {
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

    public func calculate(input: TranferAmountInput) throws -> TransferAmount {
        if input.assetBalance.available == 0 {
            throw TransferAmountCalculatorError.insufficientBalance(input.asset)
        }
        
        NSLog("input.value: \(input.value)")
        NSLog("input.availableValue: \(input.availableValue)")
        NSLog("input.assetBalance.available: \(input.assetBalance.available)")
        
        //TODO: Check for input.value + input.fee
        
        if input.availableValue < input.value  {
            throw TransferAmountCalculatorError.insufficientBalance(input.asset)
        }
        
        if input.assetFeeBalance.available < input.fee {
            throw TransferAmountCalculatorError.insufficientNetworkFee(input.assetFee)
        }
        
        // max value transfer
        if input.assetBalance.available == input.value {
            if input.asset == input.asset.feeAsset {
                return TransferAmount(value: input.assetBalance.available - input.fee, networkFee: input.fee, useMaxAmount: true)
            }
            return TransferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }
        
        return TransferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
    }
}
