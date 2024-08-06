// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import WalletCorePrimitives

// MARK: - ChainFeeCalculateable

extension BitcoinService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        async let getRates = getFeeRates()
        async let getUtxos = getUtxos(address: input.senderAddress)

        let (rates, utxos) = try await (getRates, getUtxos)
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, feeRates: rates, utxos: utxos)
    }

    public func getFeeRates() async -> [FeeRate] {
        await Task.concurrentResults(for: FeePriority.allCases) { rate in
            try await getFeeRate(priority: rate)
        }
        // TODO: - review such cases
        .filter({ $0.value > 0 })  // added filtering on positive types, since some on nodes returned negative values
    }

    private func getFeeRate(priority: FeePriority) async throws -> FeeRate {
        let targetBlocks = priority.blocks(chain: chain)
        let fee = try await provider
            .request(.fee(priority: targetBlocks))
            .map(as: BitcoinFeeResult.self)
        let rate = try BigInt.from(fee.result, decimals: Int(chain.chain.asset.decimals))
        return FeeRate(priority: priority, rate: rate)
    }
}

// MARK: - Models extensions

extension FeePriority {
    func blocks(chain: BitcoinChain) -> Int {
        switch chain {
        case .bitcoin: bitcoin
        case .doge: doge
        case .litecoin: litecoin
        }
    }

    var bitcoin: Int {
        // Block Time: Approximately 10 minute
        switch self {
        case .slow: 12 // 6-12 blocks (60-120 minutes)
        case .normal: 6 // 3-6 blocks (30-60 minutes)
        case .fast: 1 // 1 block (10 minutes)
        }
    }

    var doge: Int {
        // Block Time: Approximately 1 minute
        switch self {
        case .slow: 24 // 12-24 blocks (12-24 minutes)
        case .normal: 12 // 6-12 blocks (6-12 minutes)
        case .fast: 1 // 1 block (1 minute)
        }
    }

    var litecoin: Int {
        // Block Time: Approximately 2.5 minutes
        switch self {
        case .slow: 12 // 6-12 blocks (15-30 minutes)
        case .normal: 6 // 3-6 blocks (7.5-15 minutes)
        case .fast: 1 // 1 block (2.5 minutes)
        }
    }
}

extension Task {
    static func concurrentResults<T: Sendable, R: Sendable>(
        for items: [T],
        _ task: @Sendable @escaping (T) async throws -> R
    ) async -> [R] {
        await withTaskGroup(of: R?.self) { group in
            for item in items {
                group.addTask {
                    do {
                        return try await task(item)
                    } catch {
                        return nil
                    }
                }
            }

            var results: [R] = []
            for await result in group {
                if let value = result {
                    results.append(value)
                }
            }
            return results
        }
    }
}

// MARK: - Models

extension BitcoinService {
    enum BitcoinFeeCalculatorError: LocalizedError {
        case feeRateMissed
        case cantEstimateFee
        case incorrectAmount
    }

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
                throw BitcoinFeeCalculatorError.incorrectAmount
            }

            guard let feeRate = feeRates.first(where: { feePriority == $0.priority }) else {
                throw BitcoinFeeCalculatorError.feeRateMissed
            }

            let coinType = chain.chain.coinType
            let byteFee = feeRate.value
            let gasPrice = max(byteFee.int / 1000, chain.minimumByteFee)
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

            guard plan.error == CommonSigningError.ok else {
                throw BitcoinFeeCalculatorError.cantEstimateFee
            }

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
