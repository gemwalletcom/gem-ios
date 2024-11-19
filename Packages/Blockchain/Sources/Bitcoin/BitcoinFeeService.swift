// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import WalletCorePrimitives
import Gemstone

// MARK: - ChainFeeCalculateable

extension BitcoinService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        async let getRates = feeRates()
        async let getUtxos = getUtxos(address: input.senderAddress)

        let (rates, utxos) = try await (getRates, getUtxos)
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, feeRates: rates, utxos: utxos)
    }

    public func feeRates() async -> [FeeRate] {
        await ConcurrentTask.results(for: FeePriority.allCases) { rate in
            try await getFeeRate(priority: rate)
        }
    }

    private func getFeeRate(priority: FeePriority) async throws -> FeeRate {
        let blocksFeePriority = Config.shared.config(for: chain).blocksFeePriority
        let feePriority = switch priority {
        case .slow: blocksFeePriority.slow
        case .normal: blocksFeePriority.normal
        case .fast: blocksFeePriority.fast
        }
        let feePriorityValue = try await getFeePriority(for: feePriority.asInt)
        let rate = try BigInt.from(feePriorityValue, decimals: Int(chain.chain.asset.decimals))
        return FeeRate(priority: priority, rate: rate)
    }
}

// MARK: - Models

extension BitcoinService {
    struct BitcoinFeeCalculator {
        static func calculate(chain: BitcoinChain, feeInput: FeeInput, feeRates: [FeeRate], utxos: [UTXO]) throws -> Fee {
            try Self.calculate(
                chain: chain,
                senderAddress: feeInput.senderAddress,
                destinationAddress: feeInput.destinationAddress,
                amount: feeInput.value,
                isMaxAmount: feeInput.isMaxAmount,
                feePriority: feeInput.feePriority,
                feeRates: feeRates,
                utxos: utxos
            )
        }

        static func calculate(
            chain: BitcoinChain,
            senderAddress: String,
            destinationAddress: String,
            amount: BigInt,
            isMaxAmount: Bool,
            feePriority: FeePriority,
            feeRates: [FeeRate],
            utxos: [UTXO]
        ) throws -> Fee {
            guard amount <= BigInt(Int64.max) else {
                throw ChainCoreError.incorrectAmount
            }

            guard let feeRate = feeRates.first(where: { feePriority == $0.priority }) else {
                throw ChainCoreError.feeRateMissed
            }

            let coinType = chain.chain.coinType
            let byteFee = Int(round(Double(feeRate.value.int) / 1000))

            let gasPrice = max(byteFee, chain.minimumByteFee)
            let utxo = utxos.map { $0.mapToUnspendTransaction(address: senderAddress, coinType: coinType) }
            let scripts = utxo.mapToScripts(address: senderAddress, coinType: coinType)
            let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)

            let input = BitcoinSigningInput.with {
                $0.coinType = coinType.rawValue
                $0.hashType = hashType
                $0.amount = amount.int64
                $0.byteFee = Int64(gasPrice)
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
                gasLimit: 1,
                feeRates: feeRates,
                selectedFeeRate: feeRate
            )
        }
    }
}
