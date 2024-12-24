// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import WalletCore
import PrimitivesTestKit

@testable import Blockchain

final class BitcoinFeeTests {
    let utxos: [UTXO] = [
        UTXO(
            transaction_id: "21d603f2bcf5bf3c9b653ec70f53cf6caf9ad51d304e9fbbf609832d1f9a1fec",
            vout: 0,
            value: "1100",
            address: .none
        ),
        UTXO(transaction_id: "e2751b44a4eee26cad70c6f3d41ada51def4765c209de97b422b1c6d05c0ac6e", vout: 1, value: "104810", address: .none)
    ]

    let feeRates: [FeeRate] = [
        FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: 5647)),
        FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: 3831)),
        FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 4974))
    ]

    let chain = BitcoinChain.bitcoin

    lazy var feeInput: FeeInput = {
        FeeInput(
            type: .transfer(.init(.bitcoin)),
            senderAddress: "bc1qgxe8qnqpuz0zqtgztxl77t5egf2xzh2l4ylx90",
            destinationAddress: "bc1qhgxl7yjhaazdhrfh0tzge572wkyp43h7t64fal",
            value: BigInt(105910),
            balance: BigInt(105910),
            gasPrice: feeRates[2].gasPriceType,
            memo: nil
        )
    }()

    @Test
    func testCalculateFeeSuccess() throws {
        let fee = try BitcoinService.BitcoinFeeCalculator.calculate(
            chain: chain,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            amount: feeInput.value,
            isMaxAmount: feeInput.isMaxAmount,
            gasPrice: feeInput.gasPrice.gasPrice,
            utxos: utxos
        )

        let coinType = chain.chain.coinType
        let byteFee = Int(round(Double(feeInput.gasPrice.gasPrice.asInt) / 1000.0))
        let computedGasPrice = max(byteFee, chain.minimumByteFee)

        let unspent = utxos.map { $0.mapToUnspendTransaction(address: feeInput.senderAddress, coinType: coinType) }
        let scripts = unspent.mapToScripts(address: feeInput.senderAddress, coinType: coinType)
        let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)

        let input = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = hashType
            $0.amount = feeInput.value.asInt64
            $0.byteFee = Int64(computedGasPrice)
            $0.toAddress = feeInput.destinationAddress
            $0.changeAddress = feeInput.senderAddress
            $0.utxo = unspent
            $0.scripts = scripts
            $0.useMaxAmount = feeInput.isMaxAmount
        }

        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)

        let targetFee = Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: BigInt(computedGasPrice)),
            gasLimit: 1
        )
        #expect(fee == targetFee)
    }

    @Test
    func testCalculateFeeIncorrectAmount() throws {
        let incorrectAmountFeeInput = FeeInput(
            type: feeInput.type,
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            value: BigInt(Int64.max) + 1, // Incorrect amount, too large
            balance: feeInput.balance,
            gasPrice: feeInput.gasPrice,
            memo: feeInput.memo
        )

        #expect(throws: ChainCoreError.incorrectAmount) {
            _ = try BitcoinService.BitcoinFeeCalculator.calculate(
                chain: chain,
                senderAddress: incorrectAmountFeeInput.senderAddress,
                destinationAddress: incorrectAmountFeeInput.destinationAddress,
                amount: incorrectAmountFeeInput.value,
                isMaxAmount: incorrectAmountFeeInput.isMaxAmount,
                gasPrice: incorrectAmountFeeInput.gasPrice.gasPrice,
                utxos: utxos
            )
        }
    }

    @Test
    func testCalculateFeeCantEstimateFee() throws {
        #expect(throws: ChainCoreError.cantEstimateFee) {
            _ = try BitcoinService.BitcoinFeeCalculator.calculate(
                chain: chain,
                senderAddress: feeInput.senderAddress,
                destinationAddress: feeInput.destinationAddress,
                amount: feeInput.value,
                isMaxAmount: feeInput.isMaxAmount,
                gasPrice: feeInput.gasPrice.gasPrice,
                utxos: []
            )
        }
    }
}
