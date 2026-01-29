// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import Primitives
import SwiftHTTPClient
import WalletCore

internal import GemstonePrimitives
internal import WalletCorePrimitives

final class BitcoinService: Sendable {

    let chain: BitcoinChain

    init(
        chain: BitcoinChain
    ) {
        self.chain = chain
    }

    func calculate(
        senderAddress: String,
        destinationAddress: String,
        amount: BigInt,
        isMaxAmount: Bool,
        gasPrice: BigInt,
        utxos: [UTXO]
    ) throws -> Fee {
        guard amount <= BigInt(Int64.max) else {
            throw ChainCoreError.incorrectAmount
        }

        guard !utxos.isEmpty else {
            throw ChainCoreError.cantEstimateFee
        }

        let primitiveChain = chain.chain
        let coinType = primitiveChain.coinType

        let utxo = utxos.map { $0.mapToUnspendTransaction(address: senderAddress, coinType: coinType) }
        let scripts = utxo.mapToScripts(address: senderAddress, coinType: coinType)
        let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)

        let signingInput = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = hashType
            $0.amount = amount.asInt64
            $0.byteFee = gasPrice.asInt64
            $0.toAddress = destinationAddress
            $0.changeAddress = senderAddress
            $0.utxo = utxo
            $0.scripts = scripts
            $0.useMaxAmount = isMaxAmount
            $0.zip0317 = false
        }
        let plan: BitcoinTransactionPlan = AnySigner.plan(input: signingInput, coin: coinType)

        try ChainCoreError.fromWalletCore(plan.error)

        return Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: gasPrice),
            gasLimit: 1
        )
    }

    func calculateFee(input: TransactionInput) throws -> Fee {
        return try calculate(
            senderAddress: input.senderAddress,
            destinationAddress: input.destinationAddress,
            amount: input.value,
            isMaxAmount: input.feeInput.isMaxAmount,
            gasPrice: input.gasPrice.gasPrice,
            utxos: try input.metadata.getUtxos()
        )
    }
}

extension BitcoinService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        return try calculateFee(input: try input.map()).map()
    }

    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        .none
    }
}
