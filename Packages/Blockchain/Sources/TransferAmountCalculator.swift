// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public enum TranferAmountResult {
    case amount(TranferAmount)
    case error(TranferAmount, TransferAmountCalculatorError)
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
    
    public func calculateResult(input: TranferAmountInput) -> TranferAmountResult {
        do {
            let amount = try calculate(input: input)
            return .amount(amount)
        } catch {
            let amount = TranferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
            return .error(amount, error as! TransferAmountCalculatorError)
        }
    }
    
    public func calculate(input: TranferAmountInput) throws -> TranferAmount {
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
                return TranferAmount(value: input.assetBalance.available - input.fee, networkFee: input.fee, useMaxAmount: true)
            }
            return TranferAmount(value: input.assetBalance.available, networkFee: input.fee, useMaxAmount: true)
        }
        
        return TranferAmount(value: input.value, networkFee: input.fee, useMaxAmount: false)
    }
}
