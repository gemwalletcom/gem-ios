// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import WalletCore
import PrimitivesTestKit

@testable import Blockchain

struct BitcoinServiceTests {
    let utxos: [UTXO] = [
        UTXO(
            transaction_id: "21d603f2bcf5bf3c9b653ec70f53cf6caf9ad51d304e9fbbf609832d1f9a1fec",
            vout: 0,
            value: "1100",
            address: ""
        ),
        UTXO(transaction_id: "e2751b44a4eee26cad70c6f3d41ada51def4765c209de97b422b1c6d05c0ac6e", vout: 1, value: "104810", address: "")
    ]

    let feeRates: [FeeRate] = [
        FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: 5647)),
        FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: 3831)),
        FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 4974))
    ]

    let chain = BitcoinChain.bitcoin

    var feeInput: FeeInput {
        FeeInput(
            type: .transfer(.init(.bitcoin)),
            senderAddress: "bc1qgxe8qnqpuz0zqtgztxl77t5egf2xzh2l4ylx90",
            destinationAddress: "bc1qhgxl7yjhaazdhrfh0tzge572wkyp43h7t64fal",
            value: BigInt(105910),
            balance: BigInt(105910),
            gasPrice: feeRates[2].gasPriceType,
            memo: nil
        )
    }

    @Test
    func testCalculateFeeSuccess() throws {
        let service = BitcoinService(chain: chain)
        let fee = try service.calculate(
            senderAddress: feeInput.senderAddress,
            destinationAddress: feeInput.destinationAddress,
            amount: BigInt(1000),
            isMaxAmount: feeInput.isMaxAmount,
            gasPrice: BigInt(10),
            utxos: utxos
        )
    
        let targetFee = Fee(
            fee: BigInt(1780),
            gasPriceType: .regular(gasPrice: BigInt(10)),
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
            let service = BitcoinService(chain: chain)
            _ = try service.calculate(
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
            let service = BitcoinService(chain: chain)
            _ = try service.calculate(
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
