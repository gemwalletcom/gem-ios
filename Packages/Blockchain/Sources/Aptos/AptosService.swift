// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct AptosService {
    
    let chain: Chain
    let provider: Provider<AptosProvider>
    
    public init(
        chain: Chain,
        provider: Provider<AptosProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - ChainBalanceable

extension AptosService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let resource = try await provider.request(.balance(address: address))
            .map(as: AptosResource<AptosResourceBalance>.self)
        
        let balance = BigInt(stringLiteral: resource.data.coin.value)
        return AssetBalance(assetId: chain.assetId, balance: Balance(available: balance))
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }
}

// MARK: - ChainFeeCalculateable

extension AptosService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        async let getGasPrice = provider
            .request(.gasPrice)
            .map(as: AptosGasFee.self).prioritized_gas_estimate
        //Magic number for gas usage when account exist or not.
        //gasLimit * 2 for safety
        async let getDestinationAccount = try await provider
            .request(.account(address: input.destinationAddress))
            .mapOrCatch( as: AptosAccount.self, codes: [404], result: AptosAccount(sequence_number: .empty))
        let (gasPrice, destinationAccount) = try await (getGasPrice, getDestinationAccount)
        
        let gasLimit = Int32(destinationAccount.sequence_number == .empty ? 676 : 6)

        return Fee(
            fee: BigInt(gasPrice * gasLimit),
            gasPriceType: .regular(gasPrice: BigInt(gasPrice)),
            gasLimit: BigInt(gasLimit * 2)
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension AptosService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let account = provider.request(.account(address: input.senderAddress))
            .map(as: AptosAccount.self)
        async let fee =  fee(input: input.feeInput)
        
        return try await TransactionPreload(
            sequence: Int(account.sequence_number) ?? 0,
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension AptosService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .map(as: AptosTransactionBroacast.self).hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension AptosService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: AptosTransaction.self)

        return TransactionChanges(
            state: transaction.success ? .confirmed : .pending
        )
    }
}

// MARK: - ChainSyncable

extension AptosService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainStakable

extension AptosService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension AptosService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension AptosService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainLatestBlockFetchable

extension AptosService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> String {
        throw AnyError("Not Implemented")
    }
}
