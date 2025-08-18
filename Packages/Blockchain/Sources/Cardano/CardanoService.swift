// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives
import WalletCore

public struct CardanoService: Sendable {
    
    let chain: Chain
    let gateway: GatewayService
    
    public init(
        chain: Chain,
        gateway: GatewayService
    ) {
        self.chain = chain
        self.gateway = gateway
    }
}

extension CardanoService {
    private func calculateFee(input: TransactionInput, utxos: [UTXO]) throws -> BigInt {
        let signingInput = try CardanoSigningInput.with {
            $0.utxos = try utxos.map { utxo in
                try CardanoTxInput.with {
                    $0.outPoint.txHash = try Data.from(hex: utxo.transaction_id)
                    $0.outPoint.outputIndex = UInt64(utxo.vout)
                    $0.address = utxo.address
                    $0.amount = try UInt64(string: utxo.value)
                }
            }
            $0.transferMessage.toAddress = input.destinationAddress
            $0.transferMessage.changeAddress = input.senderAddress
            $0.transferMessage.amount = input.value.asUInt
            $0.transferMessage.useMaxAmount = input.value == input.balance
            $0.ttl = 190000000
        }
        let plan: CardanoTransactionPlan = AnySigner.plan(input: signingInput, coin: .cardano)
        return BigInt(plan.fee)
    }
}

// MARK: - ChainBalanceable

extension CardanoService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        try await gateway.coinBalance(chain: chain, address: address)
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        try await gateway.tokenBalance(chain: chain, address: address, tokenIds: tokenIds)
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        try await gateway.getStakeBalance(chain: chain, address: address)
    }
}

extension CardanoService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 1)),
        ]
    }
}

extension CardanoService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        return TransactionPreload(
            utxos: try await gateway.utxos(chain: chain, address: input.senderAddress)
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension CardanoService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let utxos = input.preload.utxos
        let fee = try calculateFee(input: input, utxos: utxos)
        
        return TransactionData(
            fee: Fee(fee: fee, gasPriceType: .regular(gasPrice: 1), gasLimit: 1),
            utxos: utxos
        )
    }
}

// MARK: - ChainBroadcastable

extension CardanoService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain, data: data)
    }
}

// MARK: - ChainTransactionStateFetchable

extension CardanoService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        try await gateway.transactionStatus(chain: chain, request: request)
    }
}

// MARK: - ChainIDFetchable
 
extension CardanoService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await gateway.chainId(chain: chain)
    }
}

// MARK: - ChainLatestBlockFetchable

extension CardanoService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await gateway.latestBlock(chain: chain)
    }
}

extension CardanoService: ChainStakable, ChainTokenable, ChainAddressStatusFetchable {}
