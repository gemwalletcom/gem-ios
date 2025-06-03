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
    
    let staticBaseFee = BigInt(5000)
    let tokenAccountSize = 165
    
    public init(
        chain: Primitives.Chain,
        provider: Provider<SolanaProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension SolanaService {
    private func getAccounts(token: String, owner: String) async throws -> [SolanaTokenAccountPubkey] {
        return try await provider
            .request(.getTokenAccountsByOwner(owner: owner, token: token))
            .map(as: JSONRPCResponse<SolanaValue<[SolanaTokenAccountPubkey]>>.self).result.value
    }
    
    private func getTokenAccounts(token: String, owner: String) async throws -> [SolanaTokenAccount] {
        return try await provider
            .request(.getTokenAccountsByOwner(owner: owner, token: token))
            .map(as: JSONRPCResponse<SolanaValue<[SolanaTokenAccount]>>.self).result.value
    }

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

    private func getTokenBalances(tokenIds: [AssetId], address: String) async throws -> [Primitives.AssetBalance] {
        let balances = try await provider.requestBatch(
            tokenIds.map { .getTokenAccountsByOwner(owner: address, token: try $0.getTokenId()) })
            .map(as: [JSONRPCResponse<SolanaValue<[SolanaTokenAccount]>>].self)
            .map {
                if let account = $0.result.value.first {
                    return BigInt(stringLiteral: account.account.data.parsed.info.tokenAmount.amount)
                }
                return BigInt.zero
            }
    
        return AssetBalance.merge(assetIds: tokenIds, balances: balances)
    }

    private func getPrioritizationFees() async throws -> [Int32] {
        let fees = try await provider
            .request(.fees)
            .map(as: JSONRPCResponse<[SolanaPrioritizationFee]>.self)
            .result
        return fees.map { $0.prioritizationFee }
    }

    private func getBalance(address: String) async throws -> BigInt {
        try await provider
            .request(.balance(address: address))
            .map(as: JSONRPCResponse<SolanaBalance>.self).result.value.asBigInt
    }

    private func getEpoch() async throws -> SolanaEpoch {
        try await provider
            .request(.epoch)
            .map(as: JSONRPCResponse<SolanaEpoch>.self).result
    }

    private func getDelegations(address: String) async throws -> [SolanaStakeAccount] {
        try await provider
            .request(.stakeDelegations(address: address))
            .map(as: JSONRPCResponse<[SolanaStakeAccount]>.self).result
    }

    // https://solana.com/docs/core/fees#compute-unit-limit
    private func getBaseFee(type: TransferDataType, gasPrice: GasPriceType) throws -> Fee {
        let gasLimit = switch type {
        case .transfer, .stake, .transferNft: BigInt(100_000)
        case .generic, .swap: BigInt(420_000)
        case .account, .tokenApprove: fatalError()
        }
        let totalFee = gasPrice.gasPrice + (gasPrice.priorityFee * gasLimit / BigInt(1_000_000))
        
        return Fee(fee: totalFee, gasPriceType: gasPrice, gasLimit: gasLimit)
    }
    
    private func getSlot() async throws -> BigInt {
        try await provider
            .request(.slot)
            .map(as: JSONRPCResponse<Int>.self).result.asBigInt
    }
    
    private func getGenesisHash() async throws -> String {
        try await provider
            .request(.genesisHash)
            .map(as: JSONRPCResponse<String>.self).result
    }
}

// MARK: - ChainBalanceable

extension SolanaService: ChainBalanceable {    
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await getBalance(address: address)
        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: balance
            )
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        try await getTokenBalances(tokenIds: tokenIds, address: address)
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        let staked = try await getDelegations(address: address)
            .map { $0.account.lamports }
            .reduce(0, +)

        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(staked: BigInt(staked))
        )
    }
}

extension SolanaService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        // filter out any large fees
        let priorityFees = try await getPrioritizationFees().map { $0.asInt }.sorted(by: >).prefix(5)
        
        let multipleOf = switch type {
        case .transfer(let asset): asset.type == .native ? 50_000 : 100_000
        case .stake, .transferNft: 50_000
        case .generic, .swap: 250_000
        case .account, .tokenApprove: fatalError()
        }
        
        let priorityFee = {
            if priorityFees.isEmpty {
                BigInt(multipleOf)
            } else {
                BigInt(
                    max(
                        (priorityFees.reduce(0, +) / priorityFees.count).roundToNearest(
                            multipleOf: multipleOf,
                            mode: .up
                        ),
                        multipleOf
                    )
                )
            }
        }()
        
        return [
            FeeRate(priority: .slow, gasPriceType: .eip1559(gasPrice: staticBaseFee, priorityFee: priorityFee / 2)),
            FeeRate(priority: .normal, gasPriceType: .eip1559(gasPrice: staticBaseFee, priorityFee: priorityFee)),
            FeeRate(priority: .fast, gasPriceType: .eip1559(gasPrice: staticBaseFee, priorityFee: priorityFee * 3)),
        ]
    }
}

// MARK: - ChainTransactionPreloadable

extension SolanaService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        let blockhash = try await provider
            .request(.latestBlockhash)
            .map(as: JSONRPCResponse<SolanaBlockhashResult>.self).result.value.blockhash
        
        return TransactionPreload(blockHash: blockhash)
    }
}

extension SolanaService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let fee = try getBaseFee(type: input.type, gasPrice: input.gasPrice)
        switch input.type {
        case .generic, .transfer:
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
        case .transferNft:
            fatalError()
        case .swap, .stake:
            return TransactionData(
                block: SignerInputBlock(hash: input.preload.blockHash),
                fee: fee
            )
        case .account, .tokenApprove: fatalError()
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
        let transaction = try await provider
            .request(.transaction(id: request.id))
            .map(as: JSONRPCResponse<SolanaTransaction>.self).result
        
        if transaction.slot > 0 {
            if let _ = transaction.meta.err {
                return TransactionChanges(state: .failed)
            }
            return TransactionChanges(state: .confirmed)
        }
        return TransactionChanges(state: .pending)
    }
}

// MARK: - ChainSyncable

extension SolanaService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        return try await provider
            .request(.health)
            .map(as: JSONRPCResponse<String>.self).result == "ok"
    }
}

// MARK: - ChainStakable

extension SolanaService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        let validators = try await provider
            .request(.stakeValidators)
            .map(as: JSONRPCResponse<SolanaValidators>.self).result.current
            
        return validators.compactMap {
            let isActive = $0.epochVoteAccount
            let apr = isActive ? apr - (apr * (Double($0.commission) / 100)) : 0
            return DelegationValidator(
                chain: chain,
                id: $0.votePubkey,
                name: .empty,
                isActive: isActive,
                commision: Double($0.commission),
                apr: apr
            )
        }
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        async let getEpoch = getEpoch()
        async let getDelegations = getDelegations(address: address)
        let (epoch, delegations) = try await (getEpoch, getDelegations)
        
        return delegations.map { delegation in
            let info = delegation.account.data.parsed.info
            
            let state: DelegationState = {
                if let deactivationEpoch = Int(info.stake.delegation.deactivationEpoch) {
                    if deactivationEpoch == epoch.epoch {
                        return .deactivating
                    } else if deactivationEpoch < epoch.epoch {
                        return .awaitingWithdrawal
                    }
                } else if let activationEpoch = Int(info.stake.delegation.activationEpoch) {
                    if activationEpoch == epoch.epoch {
                        return .activating
                    } else if activationEpoch <= epoch.epoch {
                        return .active
                    }
                }
                return .pending
            }()
            let completionDate: Date? = switch state {
            case .activating, .deactivating: Date().addingTimeInterval(TimeInterval(epoch.slotsInEpoch - epoch.slotIndex) * 0.420)
            default: .none
            }
            let balance = delegation.account.lamports
            //TODO: Fix
            //let rewards = BigInt(delegation.account.lamports) - BigInt(stringLiteral: info.stake.delegation.stake)
            
            return DelegationBase(
                assetId: chain.assetId,
                state: state,
                balance: balance.description,
                shares: "0",
                rewards: .zero, //rewards.description,
                completionDate: completionDate,
                delegationId: delegation.pubkey,
                validatorId: info.stake.delegation.voter
            )
        }
    }
}

// MARK: - ChainTokenable

extension SolanaService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        let metadataKey = try Gemstone.solanaDeriveMetadataPda(mint: tokenId)
    
        async let getTokenInfo = provider.request(.getAccountInfo(account: tokenId))
            .map(as: JSONRPCResponse<SolanaSplTokenInfo>.self)
        async let getMetadata = provider.request(.getAccountInfo(account: metadataKey))
            .map(as: JSONRPCResponse<SolanaMplRawData>.self)
        
        let (tokenInfo, metadataEncoded) = try await (getTokenInfo, getMetadata)
        guard let base64Str = metadataEncoded.result.value.data.first else {
            throw AnyError("no meta account found")
        }
        let metadata = try Gemstone.solanaDecodeMetadata(base64Str: base64Str)

        return Asset(
            id: AssetId(chain: chain, tokenId: tokenId),
            name: metadata.name,
            symbol: metadata.symbol,
            decimals: tokenInfo.result.value.data.parsed.info.decimals,
            type: .spl
        )
    }

    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.count.isBetween(40, and: 60) && Base58.decodeNoCheck(string: tokenId) != nil
    }
}

// MARK: - ChainIDFetchable
 
extension SolanaService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await getGenesisHash()
    }
}

// MARK: - ChainLatestBlockFetchable

extension SolanaService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await getSlot()
    }
}

// MARK: - ChainAddressStatusFetchable

extension SolanaService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
