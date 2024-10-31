// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import Gemstone
import GemstonePrimitives

public struct SuiService: Sendable {
    
    let chain: Primitives.Chain
    let provider: Provider<SuiProvider>
    
    private static let coinId = "0x2::sui::SUI"

    public init(
        chain: Primitives.Chain,
        provider: Provider<SuiProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension SuiService {
    private func getBalance(address: String) async throws -> SuiCoinBalance {
        try await provider.request(.balance(address: address))
            .map(as: JSONRPCResponse<SuiCoinBalance>.self).result
    }

    private func getSystemState() async throws -> SuiSystemState {
        try await provider
            .request(.systemState)
            .map(as: JSONRPCResponse<SuiSystemState>.self).result
    }

    private func getDelegations(address: String) async throws -> [SuiStakeDelegation] {
        try await provider
            .request(.stakeDelegations(address: address))
            .map(as: JSONRPCResponse<[SuiStakeDelegation]>.self).result
    }

    private func getGasPrice() async throws -> BigInt {
        return try await provider
            .request(.gasPrice)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }

    private func getCoins(senderAddress: String, coinType: String) async throws -> [SuiCoin] {
        return try await provider
            .request(.coins(address: senderAddress, coinType: coinType))
            .map(as: JSONRPCResponse<SuiData<[SuiCoin]>>.self).result.data
    }

    private func getData(input: FeeInput) async throws -> String {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                try await encodeTransfer(
                    sender: input.senderAddress,
                    recipient: input.destinationAddress,
                    coinType: Self.coinId,
                    value: input.value,
                    sendMax: input.isMaxAmount
                ).data
            case .token:
                try await encodeTokenTransfer(
                    sender: input.senderAddress,
                    recipient: input.destinationAddress,
                    coinType: asset.id.tokenId!,
                    gasCoinType: Self.coinId,
                    value: input.value
                ).data
            }

        case .stake(_, let stakeType):
            switch stakeType {
            case .stake(let validator):
                try await encodeStake(
                    senderAddress: input.senderAddress,
                    validatorAddress: validator.id,
                    coinType: Self.coinId,
                    value: input.value
                ).data
            case .unstake(let delegation):
                try await encodeUnstake(
                    sender: input.senderAddress,
                    stakedId: delegation.base.delegationId,
                    coinType: Self.coinId
                ).data
            case .redelegate, .rewards, .withdraw:
                fatalError()
            }
        case .swap(_, _, let action): try {
            guard
                case .swap(_, let swapData) = action
            else {
                return ""
            }
            let output = try Gemstone.suiValidateAndHash(encoded: swapData.data)
            return SuiTxData(txData: output.txData, digest: output.hash).data
        }()

        case .generic:
            fatalError()
        }
    }

    private func gasBudget(coinType: String) -> BigInt {
        BigInt(25_000_000)
    }

    private func fetcGasPrice() async throws -> UInt64 {
        let price = try await provider.request(.gasPrice).map(as: JSONRPCResponse<String>.self).result
        return UInt64(price) ?? 750
    }

    private func fetchObject(id: String) async throws -> SuiObject {
        return try await provider.request(.getObject(id: id)).map(as: JSONRPCResponse<SuiObject>.self).result
    }

    private func encodeTransfer(
        sender: String,
        recipient: String,
        coinType: String,
        value: BigInt,
        sendMax: Bool
    ) async throws -> SuiTxData  {
        let (coins, price) = try await(
            getCoins(senderAddress: sender, coinType: coinType),
            fetcGasPrice()
        )

        let suiCoins = coins.map { $0.toGemstone() }
        let input = SuiTransferInput(
            sender: sender,
            recipient: recipient,
            amount: value.UInt,
            coins: suiCoins,
            sendMax: sendMax,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).UInt,
                price: price
            )
        )
        let output = try suiEncodeTransfer(input: input)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func encodeTokenTransfer(
        sender: String,
        recipient: String,
        coinType: String,
        gasCoinType: String,
        value: BigInt
    ) async throws -> SuiTxData  {
        let (gasCoins, coins, price) = try await(
            getCoins(senderAddress: sender, coinType: gasCoinType),
            getCoins(senderAddress: sender, coinType: coinType),
            fetcGasPrice()
        )
        guard let gas = gasCoins.first else {
            throw AnyError("no gas coin")
        }
        let input = SuiTokenTransferInput(
            sender: sender,
            recipient: recipient,
            amount: value.UInt,
            tokens: coins.map { $0.toGemstone() },
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).UInt,
                price: price
            ),
            gasCoin: gas.toGemstone())
        let output = try suiEncodeTokenTransfer(input: input)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func encodeStake(
        senderAddress: String,
        validatorAddress: String,
        coinType: String,
        value: BigInt
    ) async throws -> SuiTxData {
        let (coins, price) = try await(
            getCoins(senderAddress: senderAddress, coinType: coinType),
            self.fetcGasPrice()
        )
        let suiCoins = coins.map { $0.toGemstone() }
        let stakeInput = SuiStakeInput(
            sender: senderAddress,
            validator: validatorAddress,
            stakeAmount: value.UInt,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).UInt,
                price: price
            ),
            coins: suiCoins
        )
        let output = try suiEncodeSplitStake(input: stakeInput)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func encodeUnstake(
        sender: String,
        stakedId: String,
        coinType: String
    ) async throws -> SuiTxData {
        let (coins, price, object) = try await(
            getCoins(senderAddress: sender, coinType: coinType),
            fetcGasPrice(),
            fetchObject(id: stakedId)
        )
        guard let gas = coins.first else {
            throw AnyError("no gas coin")
        }
        let input = SuiUnstakeInput(
            sender: sender,
            stakedSui: object.objectRef,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).UInt,
                price: price
            ),
            gasCoin: gas.toGemstone()
        )
        let output = try suiEncodeUnstake(input: input)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func getCoinMetadata(id: String) async throws -> SuiCoinMetadata {
        try await provider.request(.coinMetadata(id: id))
            .map(as: JSONRPCResponse<SuiCoinMetadata>.self).result
    }
    
    private func getLatestCheckpoint() async throws -> BigInt {
        try await provider
            .request(.latestCheckpoint)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }
}

// MARK: - ChainBalanceable

extension SuiService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        async let getBalance = getBalance(address: address)

        let (balance, staked) = try await (getBalance, getStakeBalance(address: address))

        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: BigInt(stringLiteral: balance.totalBalance)
            ).merge(staked.balance)
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        let balances = try await provider.request(.balances(address: address))
            .map(as: JSONRPCResponse<[SuiCoinBalance]>.self).result
        
        return tokenIds.compactMap { tokenId in
            if let balance = balances.first(where: { $0.coinType == tokenId.tokenId }) {
                return AssetBalance(
                    assetId: tokenId,
                    balance: Balance(
                        available: BigInt(stringLiteral: balance.totalBalance)
                    )
                )
            }
            return AssetBalance(
                assetId: tokenId,
                balance: Balance(available: .zero)
            )
        }
    }


    public func getStakeBalance(address: String) async throws -> AssetBalance {
        let delegations = try await getDelegations(address: address)
        let staked = delegations.map { $0.stakes.map { $0.total }.reduce(0, +) }.reduce(0, +)
        
        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: .zero,
                staked: staked
            )
        )
    }
}

// MARK: - ChainFeeCalculateable

extension SuiService: ChainFeeCalculateable {
    public func feeRates() async throws -> [FeeRate] { fatalError("not implemented") }
    
    public func fee(input: FeeInput) async throws -> Fee {
        let data: String = try await String(getData(input: input).split(separator: "_")[0])
        return try await fee(data: data)
    }

    public func fee(data: String) async throws -> Fee {
        let gasUsed = try await provider
            .request(.dryRun(data: data))
            .map(as: JSONRPCResponse<SuiTransaction>.self).result.effects.gasUsed

        let computationCost = BigInt(stringLiteral: gasUsed.computationCost)
        let storageCost = BigInt(stringLiteral: gasUsed.storageCost)
        let storageRebate = BigInt(stringLiteral: gasUsed.storageRebate)
        let fee = computationCost + storageCost - storageRebate

        return Fee(
            fee: fee,
            gasPriceType: .regular(gasPrice: 1),
            gasLimit: 1,
            feeRates: [],
            selectedFeeRate: nil
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension SuiService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        let data: String = try await getData(input: input.feeInput)
        let fee = try await fee(data: String(data.split(separator: "_")[0]))

        return TransactionPreload(
            fee: fee,
            messageBytes: data
        )
    }
}

// MARK: - ChainBroadcastable

extension SuiService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let parts = data.split(separator: "_")
        let data = String(parts[0])
        let signature = String(parts[1])
        
        return try await provider
            .request(.broadcast(data: data, signature: signature))
            .mapOrError(
                as: JSONRPCResponse<SuiBroadcastTransaction>.self,
                asError: JSONRPCError.self
            )
            .result.digest
    }
}

// MARK: - ChainTransactionStateFetchable

extension SuiService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: JSONRPCResponse<SuiTransaction>.self).result
        let state: TransactionState = switch transaction.effects.status.status {
        case "success": .confirmed
        case "failure": .reverted
        default: .pending
        }
        return TransactionChanges(state: state)
    }
}

// MARK: - ChainSyncable

extension SuiService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension SuiService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        try await provider
            .request(.stakeValidators)
            .map(as: JSONRPCResponse<SuiValidators>.self).result.apys
            .map {
                DelegationValidator(
                    chain: chain,
                    id: $0.address,
                    name: .empty,
                    isActive: true,
                    commision: 0,
                    apr: apr
                )
            }
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        async let getSystemState = getSystemState()
        async let getDelegations = getDelegations(address: address)
        let (systemState, delegations) = try await (getSystemState, getDelegations)
        
        return delegations.map { delegation in
            delegation.stakes.map { stake in
                
                let completionDate: Date? = switch stake.state {
                case .activating: systemState.epochStartDate.addingTimeInterval(systemState.epochDuration)
                    default: .none
                }
                
                return DelegationBase(
                    assetId: chain.assetId,
                    state: stake.state,
                    balance: stake.principal,
                    shares: "0",
                    rewards: stake.estimatedReward ?? .zero,
                    completionDate: completionDate,
                    delegationId: stake.stakedSuiId,
                    validatorId: delegation.validatorAddress
                )
            }
            
        }.flatMap { $0 }
    }
}

// MARK: - ChainIDFetchable
 
extension SuiService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await provider
            .request(.chainID)
            .map(as: JSONRPCResponse<String>.self).result
    }
}
// MARK: - ChainLatestBlockFetchable

extension SuiService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await getLatestCheckpoint()
    }
}

// MARK: - ChainTokenable

extension SuiService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        let data = try await getCoinMetadata(id: tokenId)
        let assetId = AssetId(chain: chain, tokenId: tokenId)
        
        return Asset(
            id: assetId,
            name: data.name,
            symbol: data.symbol,
            decimals: data.decimals,
            type: assetId.assetType!
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.hasPrefix("0x") && tokenId.count.isBetween(66, and: 100)
    }
}

// MARK: - Models extensions

extension SuiStake {
    var state: DelegationState {
        switch status {
        case "Active": return .active
        case "Pending": return .activating
        default: return .pending
        }
    }
    
    var total: BigInt {
        BigInt(stringLiteral: principal) + BigInt(stringLiteral: estimatedReward ?? .zero)
    }
}

extension SuiSystemState {
    var epochStartDate: Date {
        Date(timeIntervalSince1970: (TimeInterval(epochStartTimestampMs) ?? 0) / 1000)
    }

    var epochDuration: TimeInterval {
        (TimeInterval(epochDurationMs) ?? 0) / 1000
    }
}

// FIXME: - update uniffi to latest to extension Codable

extension Blockchain.SuiCoin {
    func toGemstone() -> Gemstone.SuiCoin {
        Gemstone.SuiCoin(
            coinType: coinType,
            balance: BigInt(stringLiteral: balance).UInt,
            objectRef: SuiObjectRef(
                objectId: coinObjectId,
                digest: digest,
                version: BigInt(stringLiteral: version).UInt
            )
        )
    }
}

// MARK: - ChainAddressStatusFetchable

extension SuiService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
