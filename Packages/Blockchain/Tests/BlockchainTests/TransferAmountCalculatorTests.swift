// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Blockchain
import Primitives
import BigInt

final class TransferAmountCalculatorTests: XCTestCase {

    let coinAsset = Asset(.ethereum)
    
    let tokenAsset = Asset(id: AssetId(chain: .ethereum, tokenId: "0x1"), name: "", symbol: "", decimals: 0, type: .erc20)
    
    let service = TransferAmountCalculator()
    
    func testTransferCoin() {
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: BigInt(10),
                availableValue: .zero,
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(10)),
                fee: BigInt(1),
                canChangeValue: true
            ))
        )
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: .zero,
                availableValue: BigInt(0),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: BigInt(1),
                canChangeValue: true
            ))
        )
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: .zero,
                value: .zero,
                availableValue: .zero,
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: .zero),
                fee: .zero,
                canChangeValue: true
            ))
        )
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(10),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            )),
            TransferAmount(value: 10, networkFee: 1, useMaxAmount: false)
        )
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(11),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            )),
            TransferAmount(value: 11, networkFee: 1, useMaxAmount: false)
        )
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true
            )),
            TransferAmount(value: 9, networkFee: 3, useMaxAmount: true)
        )
    }

    func testTransferToken() {
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: tokenAsset,
                assetBalance: Balance(available: BigInt(12)),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: tokenAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(3)),
                fee: BigInt(4),
                canChangeValue: true
            ))
        )
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: tokenAsset,
                assetBalance: Balance(available: BigInt(12)),
                value: BigInt(1),
                availableValue: BigInt(12),
                assetFee: tokenAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(0)),
                fee: BigInt(1),
                canChangeValue: true
            ))
        )
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(3)),
                fee: BigInt(3),
                canChangeValue: true
            )),
            TransferAmount(value: 9, networkFee: 3, useMaxAmount: true)
        )
    }
    
    func testClaimRewards() {
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(1000),
                availableValue: BigInt(1000),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            )),
            TransferAmount(value: 1000, networkFee: 1, useMaxAmount: true)
        )
        
        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(1000),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(1),
                canChangeValue: true
            ))
        )
    }

    func testCanChangeValue() {
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true
            )),
            TransferAmount(value: 9, networkFee: 3, useMaxAmount: true)
        )

        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(12),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: false
            ))
        )
    }

    func testignoreValueCheck() {
        XCTAssertEqual(
            try? service.calculate(input: TranferAmountInput(
                asset: coinAsset,
                assetBalance: Balance(available: 12),
                value: BigInt(2222),
                availableValue: BigInt(12),
                assetFee: coinAsset.feeAsset,
                assetFeeBalance: Balance(available: BigInt(12)),
                fee: BigInt(3),
                canChangeValue: true,
                ignoreValueCheck: true
            )),
            TransferAmount(value: 2222, networkFee: 3, useMaxAmount: false)
        )

        XCTAssertThrowsError(
            try service.calculate(input: TranferAmountInput(
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
        )
    }
}
