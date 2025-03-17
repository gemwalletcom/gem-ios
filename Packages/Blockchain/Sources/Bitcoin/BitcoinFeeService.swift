// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import WalletCorePrimitives
import Gemstone
import GemstonePrimitives

// MARK: - ChainFeeCalculateable

extension BitcoinService {
    public func fee(input: FeeInput, utxos: [UTXO]) throws -> Fee {
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, utxos: utxos)
    }

    private func getFeeRate(priority: FeePriority) async throws -> FeeRate {
        let blocksFeePriority = Config.shared.config(for: chain).blocksFeePriority
        let feePriority = switch priority {
        case .slow: blocksFeePriority.slow
        case .normal: blocksFeePriority.normal
        case .fast: blocksFeePriority.fast
        }
        let feePriorityValue = try await getFeePriority(for: feePriority.asInt)
        let rate = try BigInt.from(feePriorityValue, decimals: Int(chain.chain.asset.decimals)) / 1000
        return FeeRate(priority: priority, gasPriceType: .regular(gasPrice: max(rate, BigInt(chain.minimumByteFee))))
    }
}

extension BitcoinService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async -> [FeeRate] {
        await ConcurrentTask.results(for: FeePriority.allCases) {
            try await getFeeRate(priority: $0)
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



