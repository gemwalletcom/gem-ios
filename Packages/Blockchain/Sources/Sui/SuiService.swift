// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import struct Gemstone.SuiCoin
import func Gemstone.suiEncodeSplitStake
import func Gemstone.suiEncodeTokenTransfer
import func Gemstone.suiEncodeTransfer
import func Gemstone.suiEncodeUnstake
import struct Gemstone.SuiGas
import struct Gemstone.SuiObjectRef
import struct Gemstone.SuiStakeInput
import struct Gemstone.SuiTokenTransferInput
import struct Gemstone.SuiTransferInput
import struct Gemstone.SuiUnstakeInput
import func Gemstone.suiValidateAndHash
import GemstonePrimitives
import Primitives
import SwiftHTTPClient

public struct SuiService: Sendable {
    let chain: Primitives.Chain
    let provider: Provider<SuiProvider>
    let gateway: GatewayService

    private static let coinId = "0x2::sui::SUI"

    public init(
        chain: Primitives.Chain,
        provider: Provider<SuiProvider>,
        gateway: GatewayService
    ) {
        self.chain = chain
        self.provider = provider
        self.gateway = gateway
    }
}

// MARK: - Business Logic

extension SuiService {

    private func getSystemState() async throws -> SuiSystemState {
        try await provider
            .request(.systemState)
            .mapOrError(as: JSONRPCResponse<SuiSystemState>.self, asError: JSONRPCError.self).result
    }


    private func getGasPrice() async throws -> BigInt {
        return try await provider
            .request(.gasPrice)
            .mapOrError(as: JSONRPCResponse<BigIntable>.self, asError: JSONRPCError.self).result.value
    }

    private func getCoins(senderAddress: String, coinType: String) async throws -> [SuiCoin] {
        return try await provider
            .request(.coins(address: senderAddress, coinType: coinType))
            .mapOrError(as: JSONRPCResponse<SuiData<[SuiCoin]>>.self, asError: JSONRPCError.self).result.data
    }

    private func getData(input: FeeInput) async throws -> String {
        switch input.type {
        case .transfer(let asset), .deposit(let asset):
            switch asset.id.type {
            case .native:
                try await encodeTransfer(
                    sender: input.senderAddress,
                    recipient: input.destinationAddress,
                    coinType: Self.coinId,
                    value: input.value,
                    gasPrice: input.gasPrice.gasPrice,
                    sendMax: input.isMaxAmount
                ).data
            case .token:
                try await encodeTokenTransfer(
                    sender: input.senderAddress,
                    recipient: input.destinationAddress,
                    coinType: asset.id.getTokenId(),
                    gasCoinType: Self.coinId,
                    value: input.value,
                    gasPrice: input.gasPrice.gasPrice
                ).data
            }
        case .transferNft, .withdrawal:
            throw AnyError.notImplemented
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake(let validator):
                try await encodeStake(
                    senderAddress: input.senderAddress,
                    validatorAddress: validator.id,
                    coinType: Self.coinId,
                    value: input.value,
                    gasPrice: input.gasPrice.gasPrice
                ).data
            case .unstake(let delegation):
                try await encodeUnstake(
                    sender: input.senderAddress,
                    stakedId: delegation.base.delegationId,
                    coinType: Self.coinId,
                    gasPrice: input.gasPrice.gasPrice
                ).data
            case .redelegate, .rewards, .withdraw:
                fatalError()
            }
        case .swap(_, _, let data): try {
            let output = try suiValidateAndHash(encoded: data.data.data)
            return SuiTxData(txData: output.txData, digest: output.hash).data
        }()
        case .generic, .account, .tokenApprove, .perpetual: fatalError()
        }
    }

    private func gasBudget(coinType: String) -> BigInt {
        BigInt(25_000_000)
    }

    private func fetchObject(id: String) async throws -> SuiObject {
        return try await provider.request(.getObject(id: id)).mapOrError(as: JSONRPCResponse<SuiObject>.self, asError: JSONRPCError.self).result
    }

    private func encodeTransfer(
        sender: String,
        recipient: String,
        coinType: String,
        value: BigInt,
        gasPrice: BigInt,
        sendMax: Bool
    ) async throws -> SuiTxData {
        let coins = try await getCoins(senderAddress: sender, coinType: coinType)

        let suiCoins = coins.map { $0.toGemstone() }
        let input = SuiTransferInput(
            sender: sender,
            recipient: recipient,
            amount: value.asUInt,
            coins: suiCoins,
            sendMax: sendMax,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).asUInt,
                price: gasPrice.asUInt
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
        value: BigInt,
        gasPrice: BigInt
    ) async throws -> SuiTxData {
        async let getGasCoins = getCoins(senderAddress: sender, coinType: gasCoinType)
        async let getCoins = getCoins(senderAddress: sender, coinType: coinType)
        let (gasCoins, coins) = try await (getGasCoins, getCoins)

        guard let gas = gasCoins.first else {
            throw AnyError("no gas coin")
        }
        let input = SuiTokenTransferInput(
            sender: sender,
            recipient: recipient,
            amount: value.asUInt,
            tokens: coins.map { $0.toGemstone() },
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).asUInt,
                price: gasPrice.asUInt
            ),
            gasCoin: gas.toGemstone()
        )
        let output = try suiEncodeTokenTransfer(input: input)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func encodeStake(
        senderAddress: String,
        validatorAddress: String,
        coinType: String,
        value: BigInt,
        gasPrice: BigInt
    ) async throws -> SuiTxData {
        let coins = try await getCoins(senderAddress: senderAddress, coinType: coinType)
        let suiCoins = coins.map { $0.toGemstone() }
        let stakeInput = SuiStakeInput(
            sender: senderAddress,
            validator: validatorAddress,
            stakeAmount: value.asUInt,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).asUInt,
                price: gasPrice.asUInt
            ),
            coins: suiCoins
        )
        let output = try suiEncodeSplitStake(input: stakeInput)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func encodeUnstake(
        sender: String,
        stakedId: String,
        coinType: String,
        gasPrice: BigInt
    ) async throws -> SuiTxData {
        async let getCoins = getCoins(senderAddress: sender, coinType: coinType)
        async let getObject = fetchObject(id: stakedId)
        let (coins, object) = try await (getCoins, getObject)

        guard let gas = coins.first else {
            throw AnyError("no gas coin")
        }
        let input = SuiUnstakeInput(
            sender: sender,
            stakedSui: object.objectRef,
            gas: SuiGas(
                budget: gasBudget(coinType: coinType).asUInt,
                price: gasPrice.asUInt
            ),
            gasCoin: gas.toGemstone()
        )
        let output = try suiEncodeUnstake(input: input)
        return SuiTxData(txData: output.txData, digest: output.hash)
    }

    private func getCoinMetadata(id: String) async throws -> SuiCoinMetadata {
        try await provider.request(.coinMetadata(id: id))
            .mapOrError(as: JSONRPCResponse<SuiCoinMetadata>.self, asError: JSONRPCError.self).result
    }

    private func getLatestCheckpoint() async throws -> BigInt {
        try await provider
            .request(.latestCheckpoint)
            .mapOrError(as: JSONRPCResponse<BigIntable>.self, asError: JSONRPCError.self).result.value
    }
}

// MARK: - ChainBalanceable

extension SuiService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        try await gateway.coinBalance(chain: chain, address: address)
    }

    public func tokenBalance(for address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway.tokenBalance(chain: chain, address: address, tokenIds: tokenIds)
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        try await gateway.getStakeBalance(chain: chain, address: address)
    }
}

// MARK: - ChainFeeCalculateable

public extension SuiService {
    func fee(input: FeeInput) async throws -> Fee {
        let data: String = try await String(getData(input: input).split(separator: "_")[0])
        return try await fee(data: data)
    }

    func fee(data: String) async throws -> Fee {
        let gasUsed = try await provider
            .request(.dryRun(data: data))
            .mapOrError(as: JSONRPCResponse<SuiTransaction>.self, asError: JSONRPCError.self)
            .result.effects.gasUsed

        let computationCost = BigInt(stringLiteral: gasUsed.computationCost)
        let storageCost = BigInt(stringLiteral: gasUsed.storageCost)
        let storageRebate = BigInt(stringLiteral: gasUsed.storageRebate)
        let fee = max(computationCost, computationCost + storageCost - storageRebate)

        return Fee(
            fee: fee,
            gasPriceType: .regular(gasPrice: 1),
            gasLimit: 1
        )
    }
}

extension SuiService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        try [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: await getGasPrice()))
        ]
    }
}

extension SuiService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        .none
    }
}

// MARK: - ChainTransactionPreloadable

extension SuiService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let data: String = try await getData(input: input.feeInput)
        let fee = try await fee(data: String(data.split(separator: "_")[0]))

        return TransactionData(
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
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: request.id))
            .mapOrError(as: JSONRPCResponse<SuiTransaction>.self, asError: JSONRPCError.self).result
        let state: TransactionState = switch transaction.effects.status.status {
        case "success": .confirmed
        case "failure": .reverted
        default: .pending
        }
        return TransactionChanges(state: state)
    }
}

// MARK: - ChainStakable

extension SuiService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        try await provider
            .request(.stakeValidators)
            .mapOrError(as: JSONRPCResponse<SuiValidators>.self, asError: JSONRPCError.self).result.apys
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
            .mapOrError(as: JSONRPCResponse<String>.self, asError: JSONRPCError.self).result
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

        return try Asset(
            id: assetId,
            name: data.name,
            symbol: data.symbol,
            decimals: data.decimals,
            type: assetId.getAssetType()
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
            balance: BigInt(stringLiteral: balance).asUInt,
            objectRef: SuiObjectRef(
                objectId: coinObjectId,
                digest: digest,
                version: BigInt(stringLiteral: version).asUInt
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

