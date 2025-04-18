// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Blockchain
import Primitives
import BigInt
import Testing

struct TransferAmountCalculatorTests {
    let coinAsset = Asset(.ethereum)
    let tokenAsset = Asset(
        id: AssetId(chain: .ethereum, tokenId: "0x1"),
        name: "",
        symbol: "",
        decimals: 0,
        type: .erc20
    )
    let service = TransferAmountCalculator()

    @Test
    func testTransferCoin() {
        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: BigInt(10),
                availableValue: .zero,
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(10)),
                fee: BigInt(1),
                canChangeValue: true
            ))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: .zero,
                availableValue: BigInt(0),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: BigInt(1),
                canChangeValue: true
            ))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: BigInt(10)),
                value: BigInt(20),
                availableValue: BigInt(10),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(100)),
                fee: BigInt(0),
                canChangeValue: true
            ))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: BigInt(10),
                availableValue: .zero,
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: .zero,
                fee: .zero,
                canChangeValue: true
            ))
        }

        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: .zero,
                availableValue: .zero,
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: .zero,
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: .zero, networkFee: .zero, useMaxAmount: true))
        }

        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: BigInt(100)),
                value: BigInt(50),
                availableValue: BigInt(100),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(100)),
                fee: .zero,
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 50, networkFee: .zero, useMaxAmount: false))
        }

        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(10),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 10, networkFee: 1, useMaxAmount: false))
        }

        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(11),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 11, networkFee: 1, useMaxAmount: false))
        }

        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 9, networkFee: 3, useMaxAmount: true))
        }
    }

    @Test
    func testClaimRewards() {
        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(1000),
                availableValue: BigInt(1000),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 1000, networkFee: 1, useMaxAmount: true))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(1000),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            ))
        }
    }

    func testCanChangeValue() {
        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true
            ))
            #expect(result == TransferAmount(value: 9, networkFee: 3, useMaxAmount: true))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: false
            ))
        }
    }

    @Test
    func testIgnoreValueCheck() {
        #expect(throws: Never.self) {
            let result = try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(2222),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true,
                ignoreValueCheck: true
            ))
            #expect(result == TransferAmount(value: 2222, networkFee: 3, useMaxAmount: false))
        }

        #expect(throws: TransferAmountCalculatorError.insufficientNetworkFee(coinAsset)) {
            try service.calculate(input: TransferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(2222),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(13),
                canChangeValue: true,
                ignoreValueCheck: true
            ))
        }
    }
    
    @Test
    func testBalancePreCheck() {
        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.validateBalance(
                asset: coinAsset,
                assetBalance: .zero,
                value: BigInt(10),
                availableValue: BigInt(10),
                ignoreValueCheck: false,
                canChangeValue: true
            )
        }

        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.validateBalance(
                asset: coinAsset,
                assetBalance: Balance(available: BigInt(10)),
                value: BigInt(20),
                availableValue: BigInt(10),
                ignoreValueCheck: false,
                canChangeValue: true
            )
        }

        #expect(throws: Never.self) {
            try service.validateBalance(
                asset: coinAsset,
                assetBalance: .zero,
                value: BigInt(10),
                availableValue: BigInt(10),
                ignoreValueCheck: true,
                canChangeValue: false
            )
        }

        #expect(throws: Never.self) {
            try service.validateBalance(
                asset: coinAsset,
                assetBalance: Balance(available: BigInt(50)),
                value: BigInt(20),
                availableValue: BigInt(50),
                ignoreValueCheck: false,
                canChangeValue: false
            )
        }
        
        #expect(throws: TransferAmountCalculatorError.insufficientBalance(coinAsset)) {
            try service.validateBalance(
                asset: coinAsset,
                assetBalance: Balance(available: BigInt(0)),
                value: BigInt(10000),
                availableValue: BigInt(0),
                ignoreValueCheck: false,
                canChangeValue: true
            )
        }
    }
    
    @Test
    func testMinimumAccountBalance() {
        let asset1 = Asset(.solana)
        
        #expect(throws: TransferAmountCalculatorError.minimumAccountBalanceTooLow(asset1)) {
            try service.calculate(input: TransferAmountInput(
                asset: asset1,
                assetBalance: Balance(available: BigInt(1000890880)),
                value: BigInt(1000590880),
                availableValue: BigInt(1000890880),
                assetFee: asset1.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: .zero,
                canChangeValue: true
            ))
        }
        
        let asset2 = Asset(.bitcoin)
        
        #expect(throws: Never.self) {
            try service.calculate(input: TransferAmountInput(
                asset: asset2,
                assetBalance: Balance(available: BigInt(1000890880)),
                value: BigInt(1000590880),
                availableValue: BigInt(1000890880),
                assetFee: asset2.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: .zero,
                canChangeValue: true
            ))
        }
    }
}
