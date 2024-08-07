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
        async let getRates = feeRates()
        async let getUtxos = getUtxos(address: input.senderAddress)

        let (rates, utxos) = try await (getRates, getUtxos)
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, feeRates: rates, utxos: utxos)
    }

    public func feeRates() async -> [FeeRate] {
        await Task.concurrentResults(for: FeePriority.allCases) { rate in
            try await getFeeRate(priority: rate)
        }
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
        case .bitcoin, .litecoin:
            switch self {
            case .fast: 1
            case .normal: 6
            case .slow: 12
            }
        case .doge:
            switch self {
            case .fast: 2
            case .normal: 12
            case .slow: 24
            }
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
