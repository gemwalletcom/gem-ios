// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import BigInt
import Primitives
import WalletCore
import WalletCorePrimitives
import PrimitivesTestKit

@testable import Blockchain

class BitcoinFeeCalculatorTests: XCTestCase {

    let utxos: [UTXO] = [
        UTXO(transaction_id: "21d603f2bcf5bf3c9b653ec70f53cf6caf9ad51d304e9fbbf609832d1f9a1fec", vout: 0, value: "1100"),
        UTXO(transaction_id: "e2751b44a4eee26cad70c6f3d41ada51def4765c209de97b422b1c6d05c0ac6e", vout: 1, value: "104810")
    ]

    let feeRates: [FeeRate] = [
        FeeRate(priority: .fast, rate: BigInt(5647)),
        FeeRate(priority: .slow, rate: BigInt(3831)),
        FeeRate(priority: .normal, rate: BigInt(4974))
    ]

    let chain = BitcoinChain.bitcoin
    let feeInput = FeeInput(
        type: .transfer(.init(.bitcoin)),
        senderAddress: "bc1qgxe8qnqpuz0zqtgztxl77t5egf2xzh2l4ylx90",
        destinationAddress: "bc1qhgxl7yjhaazdhrfh0tzge572wkyp43h7t64fal",
        value: BigInt(105910),
        balance: BigInt(105910),
        feePriority: .normal,
        memo: nil
    )

    func testCalculateFeeSuccess() throws {
        let fee = try BitcoinService.BitcoinFeeCalculator.calculate(
            chain: chain,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            amount: feeInput.value,
            isMaxAmount: feeInput.isMaxAmount,
            feePriority: feeInput.feePriority,
            feeRates: feeRates,
            utxos: utxos
        )

        // amount: 105198
        // available_amount: 105910 => AnySigner.plan(input: input, coin: coinType).fee == 712
        XCTAssertEqual(fee.fee, BigInt(712))
        XCTAssertEqual(fee.gasPriceType, .regular(gasPrice: BigInt(4))) // Adjusted gasPrice to match the mock input
        XCTAssertEqual(fee.gasLimit, 1)
        XCTAssertEqual(fee.selectedFeeRate, feeRates[2]) // Assuming the selected fee rate is the one with normal priority
    }

    func testCalculateFeeMissingFeeRate() throws {
        let feeRates = [FeeRate(priority: .fast, rate: BigInt(5647))] // Only fast fee rate available

        XCTAssertThrowsError(try BitcoinService.BitcoinFeeCalculator.calculate(
            chain: chain,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            amount: feeInput.value,
            isMaxAmount: feeInput.isMaxAmount,
            feePriority: feeInput.feePriority,
            feeRates: feeRates,
            utxos: utxos
        )) { error in
            XCTAssertEqual(error as? BitcoinService.BitcoinFeeCalculatorError, .feeRateMissed)
        }
    }

    func testCalculateFeeIncorrectAmount() throws {
        // Create a new FeeInput instance with an incorrect amount
        let incorrectAmountFeeInput = FeeInput(
            type: feeInput.type,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            value: BigInt(Int64.max) + 1, // Incorrect amount
            balance: feeInput.balance,
            feePriority: feeInput.feePriority,
            memo: feeInput.memo
        )

        XCTAssertThrowsError(try BitcoinService.BitcoinFeeCalculator.calculate(
            chain: chain,
            senderAddress: incorrectAmountFeeInput.senderAddress,
            destinationAddress: incorrectAmountFeeInput.destinationAddress,
            amount: incorrectAmountFeeInput.value,
            isMaxAmount: incorrectAmountFeeInput.isMaxAmount,
            feePriority: incorrectAmountFeeInput.feePriority,
            feeRates: feeRates,
            utxos: utxos
        )) { error in
            XCTAssertEqual(error as? BitcoinService.BitcoinFeeCalculatorError, .incorrectAmount)
        }
    }

    func testCalculateFeeCantEstimateFee() throws {
        XCTAssertThrowsError(try BitcoinService.BitcoinFeeCalculator.calculate(
            chain: chain,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            amount: feeInput.value,
            isMaxAmount: feeInput.isMaxAmount,
            feePriority: feeInput.feePriority,
            feeRates: feeRates,
            utxos: [] // set empty utxo for such case
        )) { error in
            XCTAssertEqual(error as? BitcoinService.BitcoinFeeCalculatorError, .cantEstimateFee)
        }
    }
}
