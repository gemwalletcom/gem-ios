// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct BitcoinService: Sendable {
    
    let chain: BitcoinChain
    let provider: Provider<BitcoinProvider>
    let gateway: GetewayService
    
    public init(
        chain: BitcoinChain,
        provider: Provider<BitcoinProvider>,
        gateway: GetewayService,
    ) {
        self.chain = chain
        self.gateway = gateway
        self.provider = provider
    }
}

// MARK: - Business Logic

extension BitcoinService {
    func getUtxos(address: String) async throws -> [UTXO] {
        let address = chain.chain.fullAddress(address: address)
        return try await provider
            .request(.utxo(address: address))
            .map(as: [BitcoinUTXO].self)
            .map { $0.mapToUTXO(address: address) }
    }
    
    func getFeePriority(for blocks: Int) async throws -> String {
        try await provider
            .request(.fee(priority: blocks))
            .map(as: BitcoinFeeResult.self).result
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
        return try await TransactionPreload(
            utxos: getUtxos(address: input.senderAddress)
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
        try await gateway.transactionStatus(chain: chain.chain, hash: request.id)
    }
}

// MARK: - ChainStakable

extension BitcoinService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        []
    }
}

// MARK: - ChainTokenable

extension BitcoinService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

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

// MARK: - Models extensions

public extension UTXO {
    func mapToUnspendTransaction(address: String, coinType: CoinType) -> BitcoinUnspentTransaction {
        BitcoinUnspentTransaction.with {
            $0.outPoint.hash = Data.reverse(hexString: transaction_id)
            $0.outPoint.index = UInt32(vout)
            $0.amount = Int64(value)!
            $0.script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType).data
        }
    }
}

public extension Array where Element == BitcoinUnspentTransaction {
    func mapToScripts(address: String, coinType: CoinType) -> [String : Data] {
        return reduce(into: [String: Data]()) { map, data in
            let script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType)
            
            guard coinType != .bitcoin, !script.data.isEmpty else {
                return
            }
            if let scriptHash = script.matchPayToScriptHash() {
                map[scriptHash.hexString] = script.matchPayToWitnessPublicKeyHash()
            } else if let scriptHash = script.matchPayToWitnessPublicKeyHash() {
                map[scriptHash.hexString] = script.matchPayToPubkeyHash()
            }
       }
    }
}

// MARK: - ChainAddressStatusFetchable

extension BitcoinService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
