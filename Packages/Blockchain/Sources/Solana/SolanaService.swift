// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import func Gemstone.solanaDeriveMetadataPda
import func Gemstone.solanaDecodeMetadata
import struct GemstonePrimitives.SolanaConfig
import WalletCore

public struct SolanaService: Sendable {
    
    let chain: Primitives.Chain
    let provider: Provider<SolanaProvider>
    let gateway: GatewayService
    let feeService: SolanaFeeService
    
    let tokenAccountSize = 165
    
    public init(
        chain: Primitives.Chain,
        provider: Provider<SolanaProvider>,
        gateway: GatewayService
    ) {
        self.chain = chain
        self.provider = provider
        self.gateway = gateway
        self.feeService = SolanaFeeService()
    }
}

// MARK: - Business Logic

extension SolanaService {

    private func getTokenTransferType(
        tokenId: String,
        senderAddress: String,
        destinationAddress: String
    ) async throws -> SignerInputToken {
        let accounts = try await provider.requestBatch([
            .getTokenAccountsByOwner(owner: senderAddress, token: tokenId),
            .getTokenAccountsByOwner(owner: destinationAddress, token: tokenId)
        ])
        .map(as: [JSONRPCResponse<SolanaValue<[SolanaTokenAccount]>>].self)
        
        guard let senderToken = try accounts.getElement(safe: 0).result.value.first else {
            throw AnyError("Sender token address is empty")
        }
        let recipientTokenAccounts = try accounts.getElement(safe: 1).result.value
        let senderTokenAddress = senderToken.pubkey
        
        guard let splProgram = SolanaConfig.tokenProgramId(owner: senderToken.account.owner) else {
            throw AnyError("Unknow token program id")
        }
        
        if let recipientTokenAddress = recipientTokenAccounts.first?.pubkey {
            return SignerInputToken(
                senderTokenAddress: senderTokenAddress,
                recipientTokenAddress: recipientTokenAddress,
                tokenProgram: splProgram
            )
        }
        return SignerInputToken(
            senderTokenAddress: senderTokenAddress,
            recipientTokenAddress: .none,
            tokenProgram: splProgram
        )
    }


    private func getPrioritizationFees() async throws -> [Int] {
        let fees = try await provider
            .request(.fees)
            .map(as: JSONRPCResponse<[SolanaPrioritizationFee]>.self)
            .result
        return fees.map { $0.prioritizationFee }
    }

}

// MARK: - ChainBalanceable

extension SolanaService: ChainBalanceable {    
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

extension SolanaService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        try feeService.feeRates(type: type, prioritizationFees: try await getPrioritizationFees())
    }
}

// MARK: - ChainTransactionPreloadable

extension SolanaService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        try await gateway.transactionPreload(chain: chain, input: input)
    }
}

extension SolanaService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let fee = try feeService.getBaseFee(type: input.type, gasPrice: input.gasPrice)
        switch input.type {
        case .generic, .transfer, .deposit:
            switch input.asset.id.type {
            case .native:
                return TransactionData(
                    block: SignerInputBlock(hash: input.preload.blockHash),
                    fee: fee
                )
            case .token:
                let token = try await getTokenTransferType(
                    tokenId: try input.asset.getTokenId(),
                    senderAddress: input.senderAddress,
                    destinationAddress: input.destinationAddress
                )
                let options: FeeOptionMap = switch token.recipientTokenAddress {
                case .some: [:]
                case .none: [.tokenAccountCreation: chain.tokenActivateFee]
                }
                
                return TransactionData(
                    block: SignerInputBlock(hash: input.preload.blockHash),
                    token: token,
                    fee: fee.withOptions(options)
                )
            }
        case .transferNft, .withdrawal:
            throw AnyError.notImplemented
        case .swap, .stake:
            return TransactionData(
                block: SignerInputBlock(hash: input.preload.blockHash),
                fee: fee
            )
        case .account, .tokenApprove, .perpetual: fatalError()
        }
    }
}

// MARK: - ChainBroadcastable

extension SolanaService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(
                data: data,
                options: .init(skipPreflight: options.skipPreflight))
            )
            .mapOrError(
                as: JSONRPCResponse<String>.self,
                asError: JSONRPCError.self
            )
            .result
    }
}

// MARK: - ChainTransactionStateFetchable

extension SolanaService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        try await gateway.transactionStatus(chain: chain, request: request)
    }
}

// MARK: - ChainStakable

extension SolanaService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        try await gateway.validators(chain: chain)
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        try await gateway.delegations(chain: chain, address: address)
    }
}

// MARK: - ChainTokenable

extension SolanaService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        try await gateway.tokenData(chain: chain, tokenId: tokenId)
    }

    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.count.isBetween(40, and: 60) && Base58.decodeNoCheck(string: tokenId) != nil
    }
}

// MARK: - ChainIDFetchable
 
extension SolanaService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await gateway.chainId(chain: chain)
    }
}

// MARK: - ChainLatestBlockFetchable

extension SolanaService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await gateway.latestBlock(chain: chain)
    }
}

// MARK: - ChainAddressStatusFetchable

extension SolanaService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
