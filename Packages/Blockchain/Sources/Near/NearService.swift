// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct NearService: Sendable {
    let chain: Chain
    let provider: Provider<NearProvider>
    
    // https://docs.near.org/concepts/protocol/gas#understanding-gas-fees
    struct StaticFee {
        static let createAccount = BigInt(stringLiteral: "42000000000000000000") // 0.000042
        static let transfer = BigInt(stringLiteral: "45000000000000000000") // 0.000045
    }
    
    public init(
        chain: Chain,
        provider: Provider<NearProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension NearService {
    private func account(for address: String) async throws -> NearAccount {
        return try await provider
            .request(.account(address: address))
            .mapOrError(
                as: JSONRPCResponse<NearAccount>.self,
                asError: NearRPCError.self
            ).result
    }

    private func accountAccessKey(for address: String) async throws -> NearAccountAccessKey {
        let publicKey = "ed25519:" + Base58.encodeNoCheck(data: Data(hexString: address)!)
        return try await provider
            .request(.accountAccessKey(address: address, publicKey: publicKey))
            .mapOrError(
                as: JSONRPCResponse<NearAccountAccessKey>.self,
                asError: NearRPCError.self
            ).result
    }

    private func latestBlock() async throws -> NearBlock {
        return try await provider
            .request(.latestBlock)
            .map(as: JSONRPCResponse<NearBlock>.self).result
    }

    private func gasPrice() async throws -> BigInt {
        let result = try await provider
            .request(.gasPrice)
            .map(as: JSONRPCResponse<NearGasPrice>.self)
            .result
        return BigInt(stringLiteral: result.gas_price)
    }

    private func genesisConfig() async throws -> NearGenesisConfig {
        return try await provider
            .request(.genesisConfig)
            .map(as: JSONRPCResponse<NearGenesisConfig>.self).result
    }
}

// MARK: - ChainBalanceable

extension NearService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let account = try await account(for: address)
        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(available: BigInt(stringLiteral: account.amount))
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension NearService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let gasPrice = try await gasPrice()
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: gasPrice))
        ]
    }
}

extension NearService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        async let getAccount = try await accountAccessKey(for: input.senderAddress)
        async let getBlock = try await latestBlock()
        let (account, block) = try await (getAccount, getBlock)
        
        return TransactionPreload(
            blockhash: block.header.hash,
            sequence: account.nonce + 1
        )
    }
}

// MARK: - ChainTransactionPreloadable
// https://docs.near.org/concepts/protocol/gas#cost-for-common-actions
extension NearService: ChainTransactionLoadable {
    public func load(input: TransactionInput) async throws -> TransactionLoad {
        let transferGasLimit = BigInt(stringLiteral: "9000000000000") // BigInt(stringLiteral: "4174947687500") * 2
        let fee = Fee(
            fee: input.gasPrice.gasPrice * transferGasLimit,
            gasPriceType: .regular(gasPrice: input.gasPrice.gasPrice),
            gasLimit: 1
        )
        
        return TransactionLoad(
            sequence: input.preload.sequence,
            block: SignerInputBlock(hash: input.preload.blockhash),
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension NearService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .mapOrError(
                as: JSONRPCResponse<NearBroadcastResult>.self,
                asError: NearRPCError.self
            ).result.transaction.hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension NearService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: request.id, senderAddress: request.senderAddress))
            .map(as: JSONRPCResponse<NearBroadcastResult>.self).result
        
        switch transaction.final_execution_status {
        case "FINAL":
            return TransactionChanges(state: .confirmed)
        default:
            return TransactionChanges(state: .pending)
        }
    }
}

// MARK: - ChainSyncable

extension NearService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension NearService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        fatalError()
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension NearService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension NearService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await genesisConfig().chain_id
    }
}

// MARK: - ChainLatestBlockFetchable

extension NearService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock().header.height.asBigInt
    }
}

// MARK: - Models extensions

extension NearRPCError: LocalizedError {
    public var errorDescription: String? {
        if let data = error.data{
            return data
        }
        return error.message
    }
}

// MARK: - ChainAddressStatusFetchable

extension NearService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
