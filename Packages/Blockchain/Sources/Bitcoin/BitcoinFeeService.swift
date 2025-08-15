// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import WalletCorePrimitives
import class Gemstone.Config
import GemstonePrimitives
import Formatters

// MARK: - ChainFeeCalculateable

extension BitcoinService {
    public func fee(input: FeeInput, utxos: [UTXO]) throws -> Fee {
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, utxos: utxos)
    }
}

extension BitcoinService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws  -> [FeeRate] {
        let rates = try await gateway.fees(chain: chain.chain)
        return rates.map {
            let rate = $0.value / 1_000
            return FeeRate(
                priority: $0.priority,
                gasPriceType: .regular(gasPrice: max(rate, BigInt(chain.minimumByteFee)))
            )
        }
    }
}

// MARK: - Models

extension BitcoinService {
    struct BitcoinFeeCalculator {
        static func calculate(chain: BitcoinChain, feeInput: FeeInput, utxos: [UTXO]) throws -> Fee {
            try Self.calculate(
                chain: chain,
                senderAddress: feeInput.senderAddress,
                destinationAddress: feeInput.destinationAddress,
                amount: feeInput.value,
                isMaxAmount: feeInput.isMaxAmount,
                gasPrice: feeInput.gasPrice.gasPrice,
                utxos: utxos
            )
        }

        static func calculate(
            chain: BitcoinChain,
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

            let coinType = chain.chain.coinType
            
            let utxo = utxos.map { $0.mapToUnspendTransaction(address: senderAddress, coinType: coinType) }
            let scripts = utxo.mapToScripts(address: senderAddress, coinType: coinType)
            let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)

            let input = BitcoinSigningInput.with {
                $0.coinType = coinType.rawValue
                $0.hashType = hashType
                $0.amount = amount.asInt64
                $0.byteFee = gasPrice.asInt64
                $0.toAddress = destinationAddress
                $0.changeAddress = senderAddress
                $0.utxo = utxo
                $0.scripts = scripts
                $0.useMaxAmount = isMaxAmount
            }
            let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)

            try ChainCoreError.fromWalletCore(for: chain.chain, plan.error)
            
            return Fee(
                fee: BigInt(plan.fee),
                gasPriceType: .regular(gasPrice: BigInt(gasPrice)),
                gasLimit: 1
            )
        }
    }
}



