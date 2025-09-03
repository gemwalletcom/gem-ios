// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import GemstonePrimitives

public struct EthereumService: Sendable {
    static let gasLimitPercent = 50

    let chain: EVMChain
    let provider: Provider<EthereumTarget>
    let gatewayChainService: GatewayChainService

    public init(
        chain: EVMChain,
        provider: Provider<EthereumTarget>,
        gatewayChainService: GatewayChainService
    ) {
        self.chain = chain
        self.provider = provider
        self.gatewayChainService = gatewayChainService
    }
}

// MARK: - Business Logic

extension EthereumService {
    
    func getGasLimit(from: String, to: String, value: String?, data: String?) async throws -> BigInt {
        do {
            let gasLimit = try await provider
                .request(.estimateGasLimit(from: from, to: to, value: value, data: data))
                .mapResultOrError(as: BigIntable.self).value
            return gasLimit == BigInt(21000) ? gasLimit : BigInt(gasLimit).increase(byPercent: Self.gasLimitPercent)
        } catch let error {
            throw AnyError("Estimate gasLimit error: \(error.localizedDescription)")
        }
    }

    func getNonce(senderAddress: String) async throws -> Int {
        return try await provider
            .request(.transactionsCount(address: senderAddress))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value.asInt
    }

    func getChainId() throws -> Int {
        if let networkId = Int(GemstoneConfig.shared.getChainConfig(chain: chain.chain.rawValue).networkId) {
            return networkId
        }
        throw AnyError("Unable to get chainId")
    }
}

// MARK: - ChainBalanceable

extension EthereumService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        return try await gatewayChainService.coinBalance(for: address)
    }

    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        let requests = try tokenIds.map {
            EthereumTarget.call([
                "to": try $0.getTokenId(),
                "data": "0x70a08231000000000000000000000000\(address.remove0x)",
            ])
        }
        let balances = try await provider.requestBatch(requests)
            .map(as: [JSONRPCResponse<BigIntable>].self)
            .map(\.result.value)
        
        return AssetBalance.merge(assetIds: tokenIds, balances: balances)
    }
    
    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        try await gatewayChainService.getStakeBalance(for: address)
    }
}

// MARK: - ChainTransactionPreloadable

extension EthereumService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionLoadMetadata {
        return try await gatewayChainService.preload(input: input)
    }
}

extension EthereumService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        async let fee = fee(input: input.feeInput)
        
        return try await TransactionData(
            fee: fee,
            metadata: input.metadata
        )
    }
}

// MARK: - ChainFeeRateFetchable

extension EthereumService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        try await gatewayChainService.feeRates(type: type)
    }
}

// MARK: - ChainBroadcastable

extension EthereumService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await gatewayChainService.broadcast(data: data, options: options)
    }
}

// MARK: - ChainTransactionStateFetchable

extension EthereumService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        return try await gatewayChainService.transactionState(for: request)
    }
}

// MARK: - ChainStakable

extension EthereumService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        try await gatewayChainService.getValidators(apr: apr)
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        try await gatewayChainService.getStakeDelegations(address: address)
    }
}

// MARK: - ChainTokenable

extension EthereumService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        try await gatewayChainService.getTokenData(tokenId: tokenId)
    }

    public func getIsTokenAddress(tokenId: String) async throws -> Bool {
        try await gatewayChainService.getIsTokenAddress(tokenId: tokenId)
    }
}

// MARK: - ChainIDFetchable

extension EthereumService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        return try await gatewayChainService.getChainID()
    }
}

// MARK: - ChainLatestBlockFetchable

extension EthereumService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        return try await gatewayChainService.getLatestBlock()
    }
}

// MARK: - ChainNodeStatusFetchable

extension EthereumService: ChainNodeStatusFetchable {
    public func getNodeStatus(url: String) async throws -> NodeStatus {
        try await gatewayChainService.getNodeStatus(url: url)
    }
}

// MARK: - ChainAddressStatusFetchable

extension EthereumService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
