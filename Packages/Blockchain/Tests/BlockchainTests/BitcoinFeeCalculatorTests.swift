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
        FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: 5647)),
        FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: 3831)),
        FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 4974))
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

        let selectedFeeRate = feeRates[2]
        let coinType = chain.chain.coinType
        let byteFee = Int(round(Double(selectedFeeRate.gasPrice.int) / 1000.0))
        let gasPrice = max(byteFee, chain.minimumByteFee)

        let utxo = utxos.map { $0.mapToUnspendTransaction(address: feeInput.senderAddress, coinType: coinType) }
        let scripts = utxo.mapToScripts(address: feeInput.senderAddress, coinType: coinType)
        let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)
        let input = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = hashType
            $0.amount = feeInput.value.int64
            $0.byteFee = Int64(gasPrice)
            $0.toAddress = feeInput.destinationAddress
            $0.changeAddress = feeInput.senderAddress
            $0.utxo = utxo
            $0.scripts = scripts
            $0.useMaxAmount = feeInput.isMaxAmount
        }
        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)

        let targetFee = Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: BigInt(gasPrice)),
            gasLimit: 1,
            feeRates: feeRates,
            selectedFeeRate: selectedFeeRate
        )

        XCTAssertEqual(fee, targetFee)
    }

    func testCalculateFeeMissingFeeRate() throws {
        let feeRates = [FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: 5647))] // Only fast fee rate available

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
            XCTAssertEqual(error as? ChainCoreError, .feeRateMissed)
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
            XCTAssertEqual(error as? ChainCoreError, .incorrectAmount)
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
            XCTAssertEqual(error as? ChainCoreError, .cantEstimateFee)
        }
    }
}
