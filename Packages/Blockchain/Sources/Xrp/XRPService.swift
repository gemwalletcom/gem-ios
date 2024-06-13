// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct XRPService {
    
    let chain: Chain
    let provider: Provider<XRPProvider>
    private let reservedBalance = BigInt(10_000_000)
    
    public init(
        chain: Chain,
        provider: Provider<XRPProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
    
    func account(address: String) async throws -> XRPAccountResult {
        return try await provider
            .request(.account(address: address))
            .map(as: XRPResult<XRPAccountResult>.self).result
    }
}

extension XRPService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await account(address: address).account_data.Balance
        let available = BigInt(stringLiteral: balance) - reservedBalance
        
        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available,
                reserved: reservedBalance
            )
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }
}

extension XRPService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        let medianFee = try await provider
            .request(.fee)
            .map(as: XRPResult<XRPFee>.self).result.drops.median_fee
        let fee = BigInt(stringLiteral: medianFee)
        
        return Fee(
            fee: fee,
            gasPriceType: .regular(gasPrice: fee),
            gasLimit: 1
        )
    }
}

extension XRPService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let account = account(address: input.senderAddress)
        async let fee = fee(input: input.feeInput)

        return try await TransactionPreload(
            sequence: Int(account.account_data.Sequence),
            fee: fee
        )
    }
}

extension XRPService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let result = try await provider
            .request(.broadcast(data: data))
            .map(as: XRPResult<XRPTransactionBroadcast>.self).result
        
        if let message = result.engine_result_message, !message.isEmpty, !result.accepted  {
            throw AnyError(message)
        }
        guard let hash = result.tx_json?.hash else {
            throw AnyError("Unable to get hash")
        }
        
        return hash
    }
}

extension XRPService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let status = try await provider
            .request(.transaction(id: id))
            .map(as: XRPResult<XRPTransactionStatus>.self).result.status
        let state: TransactionState = status == "success" ? .confirmed : .pending
        return TransactionChanges(state: state)
    }
}

extension XRPService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        fatalError()
    }
}

extension XRPService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }

    public func getStakeBalance(address: String) async throws -> AssetBalance {
        fatalError()
    }
}

extension XRPService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension XRPService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        fatalError()
    }
}
