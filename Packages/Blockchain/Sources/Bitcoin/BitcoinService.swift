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
