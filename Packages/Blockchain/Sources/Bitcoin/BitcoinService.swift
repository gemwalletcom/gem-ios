// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct BitcoinService: Sendable {
    
    let chain: BitcoinChain
    let gateway: GatewayService
    
    public init(
        chain: BitcoinChain,
        gateway: GatewayService,
    ) {
        self.chain = chain
        self.gateway = gateway
    }
}

// MARK: - ChainBalanceable

extension BitcoinService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        try await gateway.coinBalance(chain: chain.chain, address: address)
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension BitcoinService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        return TransactionPreload(
            utxos: try await gateway.utxos(chain: chain.chain, address: input.senderAddress)
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension BitcoinService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let utxos = input.preload.utxos
        let fee = try fee(input: input.feeInput, utxos: utxos)
        return TransactionData(
            fee: fee,
            utxos: utxos
        )
    }
}

// MARK: - ChainBroadcastable

extension BitcoinService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain.chain, data: data)
    }
}

// MARK: - ChainTransactionStateFetchable

extension BitcoinService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        try await gateway.transactionStatus(chain: chain.chain, request: request)
    }
}

extension BitcoinService: ChainStakable, ChainTokenable {}

// MARK: - ChainIDFetchable
 
extension BitcoinService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await gateway.chainId(chain: chain.chain)
    }
}

// MARK: - ChainLatestBlockFetchable

extension BitcoinService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await gateway.latestBlock(chain: chain.chain)
    }
}

// MARK: - ChainAddressStatusFetchable

extension BitcoinService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}

extension BitcoinService {
    public func fee(input: FeeInput, utxos: [UTXO]) throws -> Fee {
        return try BitcoinFeeCalculator.calculate(chain: chain, feeInput: input, utxos: utxos)
    }
}

extension BitcoinService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws  -> [FeeRate] {
        let rates = try await gateway.feeRates(chain: chain.chain)
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
