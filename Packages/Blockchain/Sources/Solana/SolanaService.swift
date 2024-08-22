// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import Gemstone
import WalletCore

public struct SolanaService {
    
    let chain: Chain
    let provider: Provider<SolanaProvider>
    
    let staticBaseFee = BigInt(50000)
    let priorityFeeMultipler = 5
    let tokenAccountSize = 165
    
    public init(
        chain: Chain,
        provider: Provider<SolanaProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension SolanaService {
    private func getAccounts(token: String, owner: String) async throws -> [SolanaTokenAccount] {
        return try await provider
            .request(.getTokenAccountsByOwner(owner: owner, token: token))
            .map(as: JSONRPCResponse<SolanaValue<[SolanaTokenAccount]>>.self).result.value
    }

    private func getTokenTransferType(
        tokenId: String,
        senderAddress: String,
        destinationAddress: String
    ) async throws -> SignerInputToken {
        async let getSenderTokenAccounts = getAccounts(token: tokenId, owner: senderAddress)
        async let getRecipientTokenAccounts = getAccounts(token: tokenId, owner: destinationAddress)
        async let getSplProgram = getTokenProgram(tokenId: tokenId)
        let (senderTokenAccounts, recipientTokenAccounts, splProgram) = try await (getSenderTokenAccounts, getRecipientTokenAccounts, getSplProgram)

        guard let senderTokenAddress = senderTokenAccounts.first?.pubkey else {
            throw AnyError("Sender token address is empty")
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

    private func getTokenBalance(token: String, owner: String) async throws -> BigInt {
        let accounts = try await getAccounts(token: token, owner: owner)
        guard let account = accounts.first else {
            return .zero
        }
        let balance = try await provider
            .request(.getTokenAccountBalance(token: account.pubkey))
            .map(as: JSONRPCResponse<SolanaValue<SolanaBalanceValue>>.self).result.value.amount

        return BigInt(balance) ?? .zero
    }

    private func getTokenBalances(tokenIds: [AssetId], address: String) async throws -> [Primitives.AssetBalance] {
        var result: [Primitives.AssetBalance] = []
        for tokenId in tokenIds {
            guard let token = tokenId.tokenId else { break }
            let balance = try await getTokenBalance(token: token, owner: address)
            result.append(
                AssetBalance(assetId: tokenId, balance: Balance(available: balance))
            )
        }
        return result
    }

    private func getPrioritizationFee() async throws -> BigInt {
        let fees = try await provider
            .request(.fees)
            .map(as: JSONRPCResponse<[SolanaPrioritizationFee]>.self)
            .result

        return BigInt(fees.map { $0.prioritizationFee }.reduce(0, { $0 + Int($1) }) / fees.count)
    }

    private func getCoinBalance(address: String) async throws -> BigInt {
        try await provider
            .request(.balance(address: address))
            .map(as: JSONRPCResponse<SolanaBalance>.self).result.value.asBigInt
    }

    private func getEpoch() async throws -> SolanaEpoch {
        try await provider
            .request(.epoch)
            .map(as: JSONRPCResponse<SolanaEpoch>.self).result
    }

    private func getDelegations(address: String) async throws -> [SolanaTokenAccountResult<SolanaStakeAccount>] {
        try await provider
            .request(.stakeDelegations(address: address))
            .map(as: JSONRPCResponse<[SolanaTokenAccountResult<SolanaStakeAccount>]>.self).result
    }

    private func getRentExemption(size: Int) async throws -> BigInt {
        try await provider
            .request(.rentExemption(size: size))
            .map(as: JSONRPCResponse<Int>.self).result.asBigInt
    }

    private func getBaseFee() async throws -> BigInt {
        let priorityFee = try await getPrioritizationFee()
        return staticBaseFee + (priorityFee * BigInt(priorityFeeMultipler))
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
        async let getBalance = getCoinBalance(address: address)

        let (available, staked) = try await (getBalance, getStakeBalance(address: address))

        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available
            ).merge(staked.balance)
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        return try await getTokenBalances(tokenIds: tokenIds, address: address)
    }


    public func getStakeBalance(address: String) async throws -> AssetBalance {
        let staked = try await getDelegations(address: address)
            .map { $0.account.lamports }
            .reduce(0, +)
        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(available: .zero, staked: BigInt(staked))
        )
    }
}

// MARK: - ChainFeeCalculateable

extension SolanaService: ChainFeeCalculateable {
    public func feeRates() async throws -> [FeeRate] { fatalError("not implemented") }
    public func fee(input: FeeInput) async throws -> Fee {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                let fee = try await getBaseFee()
                return Fee(
                    fee: fee,
                    gasPriceType: .regular(gasPrice: fee),
                    gasLimit: 1,
                    feeRates: [],
                    selectedFeeRate: nil
                )
            case .token:
                async let getBaseFee = getBaseFee()
                async let getTokenAccountCreationFee = getRentExemption(size: tokenAccountSize)
                async let getToken = try await getTokenTransferType(
                    tokenId: try asset.getTokenId(),
                    senderAddress: input.senderAddress,
                    destinationAddress: input.destinationAddress
                )
                let (fee, tokenAccountCreationFee, token) = try await (getBaseFee, getTokenAccountCreationFee, getToken)
                
                let options: FeeOptionMap = switch token.recipientTokenAddress {
                case .some: [:]
                case .none: [.tokenAccountCreation: BigInt(tokenAccountCreationFee)]
                }
                
                return Fee(
                    fee: fee,
                    gasPriceType: .regular(gasPrice: fee),
                    gasLimit: 1,
                    options: options,
                    feeRates: [],
                    selectedFeeRate: nil
                )
            }
        case .swap, .stake:
            let fee = try await getBaseFee()
            return Fee(
                fee: fee,
                gasPriceType: .regular(gasPrice: fee),
                gasLimit: 1,
                feeRates: [],
                selectedFeeRate: nil
            )
        case .generic:
            fatalError()
        }
    }
}

// MARK: - ChainTransactionPreloadable

extension SolanaService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let blockhash = provider
            .request(.latestBlockhash)
            .map(as: JSONRPCResponse<SolanaBlockhashResult>.self).result.value.blockhash
        async let fee = fee(input: input.feeInput)

        switch input.type {
        case .generic, .transfer:
            switch input.asset.id.type {
            case .native:
                return try await TransactionPreload(
                    block: SignerInputBlock(hash: blockhash),
                    fee: fee
                )
            case .token:
                //TODO: Get tokenID from the fee
                async let token = try await getTokenTransferType(
                    tokenId: try input.asset.getTokenId(),
                    senderAddress: input.senderAddress,
                    destinationAddress: input.destinationAddress
                )
                
                return try await TransactionPreload(
                    block: SignerInputBlock(hash: blockhash),
                    token: token,
                    fee: token.recipientTokenAddress == nil ? fee.withOptions([.tokenAccountCreation]) : fee
                )
            }
        case .swap, .stake:
            return try await TransactionPreload(
                block: SignerInputBlock(hash: blockhash), 
                fee: fee
            )
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
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
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

        let tokenInfo = try await provider.request(.getAccountInfo(account: tokenId))
            .map(as: JSONRPCResponse<SolanaSplTokenInfo>.self)
            .result.value.data.parsed.info

        guard
            let base64Str = try await provider.request(.getAccountInfo(account: metadataKey))
            .map(as: JSONRPCResponse<SolanaMplRawData>.self)
            .result.value.data.first
        else {
            throw AnyError("no meta account found")
        }
        let metadata = try Gemstone.solanaDecodeMetadata(base64Str: base64Str)

        return Asset(
            id: AssetId(chain: chain, tokenId: tokenId),
            name: metadata.name,
            symbol: metadata.symbol,
            decimals: tokenInfo.decimals,
            type: .spl
        )
    }

    public func getTokenProgram(tokenId: String) async throws -> SolanaTokenProgram {
        do {
            let program = try await provider.request(.getAccountInfo(account: tokenId))
                .map(as: JSONRPCResponse<SolanaSplTokenProgram>.self)
                .result.value.data.program
            return switch program {
            case SplToken2022: .token2022
            default: .token
            }
        } catch {
            return .token
        }
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

