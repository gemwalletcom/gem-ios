// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives

public struct AlgorandService: Sendable {
    
    let chain: Chain
    let provider: Provider<AlgorandProvider>
    
    public init(
        chain: Chain,
        provider: Provider<AlgorandProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension AlgorandService {
    private func account(address: String) async throws -> AlgorandAccount {
        try await provider
            .request(.account(address: address))
            .map(as: AlgorandAccount.self)
    }
    
    private func transactionsParams() async throws -> AlgorandTransactionParams {
        try await provider
            .request(.transactionsParams)
            .map(as: AlgorandTransactionParams.self)
    }
    
    private func latestBlock() async throws -> BigInt {
        BigInt(try await transactionsParams().last_round)
    }
    
    private func reservedBalance() -> BigInt {
        BigInt(chain.accountActivationFee ?? 0)
    }
}

// MARK: - ChainBalanceable

extension AlgorandService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = BigInt(try await account(address: address).amount)
        let reserved = reservedBalance()
        let available = max(balance - reserved, .zero)

        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available,
                reserved: reserved
            )
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension AlgorandService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let params = try await transactionsParams()
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: BigInt(params.min_fee))),
        ]
    }
}

// MARK: - ChainTransactionPreloadable

extension AlgorandService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        let params = try await transactionsParams()
        return TransactionPreload(
            sequence: params.last_round.asInt,
            block: SignerInputBlock(hash: params.genesis_hash),
            chainId: params.genesis_id,
            fee: input.defaultFee
        )
    }
}

// MARK: - ChainBroadcastable

extension AlgorandService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await provider
            .request(.broadcast(data: data))
            .mapOrError(as: AlgorandTransactionBroadcast.self, asError: AlgorandTransactionBroadcastError.self)
            .txId
    }
}

// MARK: - ChainTransactionStateFetchable

extension AlgorandService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: AlgorandTransactionStatus.self)
        
        let state: TransactionState = transaction.confirmed_round > 0 ? .confirmed : .failed
        
        return TransactionChanges(state: state)
    }
}

// MARK: - ChainSyncable

extension AlgorandService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension AlgorandService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension AlgorandService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension AlgorandService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await transactionsParams().genesis_id
    }
}

// MARK: - ChainLatestBlockFetchable

extension AlgorandService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock()
    }
}


// MARK: - ChainAddressStatusFetchable

extension AlgorandService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}

extension AlgorandTransactionBroadcastError: LocalizedError {
    public var errorDescription: String? {
        message
    }
}
