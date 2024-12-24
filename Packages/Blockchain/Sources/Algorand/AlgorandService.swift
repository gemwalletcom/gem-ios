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
}

// MARK: - ChainBalanceable

extension AlgorandService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let account = try await account(address: address)
        let (available, reserved): (BigInt, BigInt) = {
            let amount = BigInt(account.amount)
            if amount > .zero {
                let reserved = BigInt(account.min_balance)
                return (
                    max(amount - reserved, .zero),
                    reserved
                )
            } else {
                return (.zero, .zero)
            }
        }()
        
        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available,
                reserved: reserved
            )
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        let assets = try await account(address: address).assets
        
        return tokenIds.map { assetId in
            let (balance, isActive): (BigInt, Bool) = {
                if let value = assets.first(where: { String($0.asset_id) == assetId.tokenId  })?.amount {
                    return (BigInt(value), true)
                }
                return (BigInt.zero, false)
            }()
            
            return AssetBalance(
                assetId: assetId,
                balance: Balance(available: balance),
                isActive: isActive
            )
        }
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
        let result = try await provider
            .request(.broadcast(data: data))
            .map(as: AlgorandTransactionBroadcast.self)
            
        if let message = result.message {
            throw AnyError(message)
        } else if let hash = result.txId {
            return hash
        }
        throw ChainServiceErrors.broadcastError(chain)
    }
}

// MARK: - ChainTransactionStateFetchable

extension AlgorandService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: request.id))
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
        let asset = try await provider
            .request(.asset(id: tokenId))
            .map(as: AlgorandAssetResponse.self).params
        
        return Asset(
            id: AssetId(chain: chain, tokenId: tokenId),
            name: asset.name,
            symbol: asset.unit_name,
            decimals: asset.decimals,
            type: .asa
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        if tokenId.count > 4, let _ = UInt64(tokenId) {
            return true
        }
        return false
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
