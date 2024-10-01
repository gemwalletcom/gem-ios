// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct CosmosService {
    
    let chain: CosmosChain
    let provider: Provider<CosmosProvider>
    
    public init(
        chain: CosmosChain,
        provider: Provider<CosmosProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension CosmosService {
    private func getAccount(address: String) async throws -> CosmosAccount {
        switch chain {
        case .cosmos,
            .osmosis,
            .celestia,
            .thorchain,
            .sei,
            .noble:
            return try await provider
                .request(.account(address: address))
                .map(as: CosmosAccountResponse<CosmosAccount>.self).account
        case .injective:
            return try await provider
                .request(.account(address: address))
                .map(as: CosmosAccountResponse<CosmosInjectiveAccount>.self).account.base_account
        }
    }

    private func getLatestCosmosBlock() async throws -> CosmosBlock {
        return try await provider
            .request(.block("latest"))
            .map(as: CosmosBlockResponse.self).block
    }

    private func getBalance(address: String) async throws -> CosmosBalances {
        try await provider
            .request(.balance(address: address))
            .map(as: CosmosBalances.self)
    }

    private func getDelegations(address: String) async throws  -> [CosmosDelegation] {
        try await provider
            .request(.delegations(address: address))
            .map(as: CosmosDelegations.self)
            .delegation_responses
    }

    private func getUnboundingDelegations(address: String) async throws  -> [CosmosUnboundingDelegation] {
        try await provider
            .request(.undelegations(address: address))
            .map(as: CosmosUnboundingDelegations.self)
            .unbonding_responses
    }

    private func getRewards(address: String) async throws -> [CosmosReward] {
        try await provider
            .request(.rewards(address: address))
            .map(as: CosmosRewards.self)
            .rewards
    }

    private func getValidatorsList() async throws -> [CosmosValidator] {
        try await provider
            .request(.validators)
            .map(as: CosmosValidators.self).validators
    }

    private func getFee(chain: CosmosChain, type: TransferDataType) -> BigInt {
        switch chain {
        case .thorchain:
            switch type {
            case .transfer: BigInt(2_000_000)
            case .stake, .swap, .generic: BigInt(4_000_000)
            }
        case .cosmos: switch type {
            case .transfer, .swap, .generic: BigInt(3_000)
            case .stake: BigInt(25_000)
        }
        case .osmosis: switch type {
            case .transfer, .swap, .generic: BigInt(10_000)
            case .stake: BigInt(100_000)
        }
        case .celestia: switch type {
            case .transfer, .swap, .generic: BigInt(3_000)
            case .stake: BigInt(10_000)
        }
        case .sei: switch type {
            case .transfer, .swap, .generic: BigInt(100_000)
            case .stake: BigInt(200_000)
        }
        case .injective: switch type {
            case .transfer, .swap, .generic: BigInt(100_000_000_000_000)
            case .stake: BigInt(1_000_000_000_000_000)
        }
        case .noble: BigInt(25_000)
        }
    }

    private func getFeeOptions(chain: CosmosChain, type: TransferDataType) -> FeeOptionMap {
        switch chain {
        case .thorchain:
            switch type {
            case let .transfer(asset):
                switch asset.id.type {
                case .native: [.outboundNativeReserved: 2_000_000]
                case .token: [:]
                }
            case .swap, .stake, .generic: [:]
            }
        case .celestia, .cosmos, .injective, .noble, .osmosis, .sei: [:]
        }
    }
}

// MARK: - ChainBalanceable

extension CosmosService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let denom = chain.denom
        
        switch chain {
        case .thorchain:
            let balances = try await getBalance(address: address);
            let balance = balances.balances.filter ({ $0.denom == denom.rawValue }).compactMap { BigInt($0.amount) }.reduce(0, +)
            
            return Primitives.AssetBalance(
                assetId: chain.chain.assetId,
                balance: Balance(
                    available: balance
                )
            )
        case .cosmos,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble:

            async let getBalance = getBalance(address: address)
            async let getStakeBalance = getStakeBalance(address: address)

            let (balances, stakeBalance) = try await (
                getBalance,
                getStakeBalance
            )
            
            let balance = balances.balances.filter ({ $0.denom == denom.rawValue }).compactMap { BigInt($0.amount) }.reduce(0, +)
            return AssetBalance(
                assetId: chain.chain.assetId,
                balance: Balance(
                    available: balance
                ).merge(stakeBalance.balance)
            )
        }
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        let balances = try await getBalance(address: address);
        return tokenIds.compactMap { assetId in
            let balance = balances.balances.filter ({ $0.denom == assetId.tokenId }).first?.amount ?? .zero
            return AssetBalance(assetId: assetId, balance: Balance(available: BigInt(stringLiteral: balance)))
        }
    }

    public func getStakeBalance(address: String) async throws -> AssetBalance {
        let denom = chain.denom
        async let getDelegations = getDelegations(address: address)
        async let getUnboundingDelegations = getUnboundingDelegations(address: address)
        async let getRewards = getRewards(address: address)

        let (delegations, unboundingDelegations, rewards) = try await(getDelegations, getUnboundingDelegations, getRewards)

        let delegationsBalance = delegations
            .filter { $0.balance.denom == denom.rawValue }
            .compactMap { BigInt($0.balance.amount) }
            .reduce(0, +)

        let unboundingDelegationsBalance = unboundingDelegations.compactMap {
            $0.entries.compactMap { BigInt($0.balance)}.reduce(0, +)
        }.reduce(0, +)

        let rewardsBalance = rewards
            .map {
                $0.reward
                    .filter { $0.denom == denom.rawValue }
                    .compactMap { BigInt($0.amount) }
                    .reduce(0, +)
            }
            .reduce(0, +)

        return AssetBalance(
            assetId: chain.chain.assetId,
            balance: Balance(
                available: .zero, // will be merged into
                staked: delegationsBalance,
                pending: unboundingDelegationsBalance,
                rewards: rewardsBalance
            )
        )
    }
}

// MARK: - ChainFeeCalculateable

extension CosmosService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        //TODO: Estimate it
        let feeValue: BigInt = getFee(chain: chain, type: input.type)
        let gasLimit: BigInt = {
            switch input.type.transactionType {
            case .transfer: BigInt(200_000)
            case .stakeDelegate,
                .stakeUndelegate: BigInt(1_000_000)
            case .stakeRedelegate: BigInt(1_250_000)
            case .stakeRewards: BigInt(750_000)
            case .swap, .tokenApproval, .stakeWithdraw:
                fatalError()
            }
        }()

        return Fee(
            fee: feeValue,
            gasPriceType: .regular(gasPrice: 1),
            gasLimit: gasLimit,
            options: getFeeOptions(chain: chain, type: input.type),
            feeRates: [],
            selectedFeeRate: nil
        )
    }

    public func feeRates() async throws -> [FeeRate] { fatalError("not implemented") }
}

// MARK: - ChainTransactionPreloadable

extension CosmosService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let account = getAccount(address: input.senderAddress)
        async let block = getLatestCosmosBlock()
        async let fee = fee(input: input.feeInput)

        return try await TransactionPreload(
            accountNumber: Int(account.account_number) ?? 0,
            sequence: Int(account.sequence) ?? 0,
            chainId: block.header.chain_id,
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension CosmosService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let response = try await provider
            .request(.broadcast(data: data))
            .map(as: CosmosBroadcastResponse.self).tx_response
        
        if response.code != 0 {
            throw AnyError(response.raw_log)
        }
        
        return response.txhash
    }
}

// MARK: - ChainTransactionStateFetchable

extension CosmosService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: CosmosTransactionResponse.self).tx_response
        if transaction.txhash.isEmpty {
            return TransactionChanges(state: .pending)
        }
        let state: TransactionState = transaction.code == 0 ? .confirmed : .reverted
        return TransactionChanges(state: state)
    }
}

// MARK: - ChainSyncable

extension CosmosService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        return try await provider
            .request(.syncing)
            .map(as: CosmosSyncing.self).syncing.inverted
    }
}

// MARK: - ChainStakable

extension CosmosService: ChainStakable {
    
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        async let getValidators = getValidatorsList()
        
        let (validators) = try await (
            getValidators
        )
        return validators.map {
            let comission = Double($0.commission.commission_rates.rate) ?? 0
            let isActive =  $0.jailed == false && $0.status == "BOND_STATUS_BONDED"
            let apr = isActive ? apr - (apr * comission) : 0
            
            return DelegationValidator(
                chain: chain.chain,
                id: $0.operator_address,
                name: $0.description.moniker,
                isActive: isActive,
                commision: comission * 100,
                apr: apr
            )
        }
    }
    
    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        async let getDelegations = getDelegations(address: address)
        async let getUnboundingDelegations = getUnboundingDelegations(address: address)
        async let getRewards = getRewards(address: address)
        async let getValidators = getValidators(apr: 0)
        
        let (delegations, unboundingDelegations, rewards, validators) = try await (
            getDelegations,
            getUnboundingDelegations,
            getRewards,
            getValidators
        )
        
        NSLog("delegations \(delegations)")
        NSLog("getUnboundingDelegations \(unboundingDelegations)")
        NSLog("getRewards \(rewards)")
        NSLog("validators \(validators.count)")
        
        let validatorsMap = validators.toMap { $0.id }
        
        let rewardsMap = rewards.toMap {
            $0.validator_address
        }.mapValues {
            $0.reward.filter { $0.denom == chain.denom.rawValue }
                .compactMap { BigInt(stringLiteral: $0.amount.components(separatedBy: ".")[0])}.reduce(0, +)
        }
        
        let baseDelegations = delegations.compactMap { delegation in
            let validator = validatorsMap[delegation.delegation.validator_address]
            let state: DelegationState = validator?.isActive ?? false ? .active : .inactive
            return DelegationBase(
                assetId: chain.chain.assetId,
                state: state,
                balance: delegation.balance.amount,
                shares: "0",
                rewards: rewardsMap[delegation.delegation.validator_address]?.description ?? .zero,
                completionDate: .none,
                delegationId: .empty,
                validatorId: delegation.delegation.validator_address
            )
        }.filter { $0.balanceValue > 0 }
        
        let baseUnbondingDelegations = unboundingDelegations.map { unboundDelegation in
            unboundDelegation.entries.map { entry in
                DelegationBase(
                    assetId: chain.chain.assetId,
                    state: .pending,
                    balance: BigInt(stringLiteral: entry.balance).description,
                    shares: "0",
                    rewards: rewardsMap[unboundDelegation.validator_address]?.description ?? .zero,
                    completionDate: Formatter.customISO8601DateFormatter.date(from: entry.completion_time),
                    delegationId: entry.creation_height,
                    validatorId: unboundDelegation.validator_address
                )
            }
        }.flatMap { $0 }
        
        return [
            baseDelegations,
            baseUnbondingDelegations,
        ]
        .flatMap{ $0 }
    }
}

// MARK: - ChainTokenable

extension CosmosService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension CosmosService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        return try await provider
            .request(.nodeInfo)
            .map(as: CosmosNodeInfoResponse.self).default_node_info.network
    }
}

// MARK: - ChainLatestBlockFetchable

extension CosmosService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        BigInt(stringLiteral: try await getLatestCosmosBlock().header.height)
    }
}
