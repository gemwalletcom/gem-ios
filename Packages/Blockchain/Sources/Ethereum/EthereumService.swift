// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import GemstonePrimitives

public struct EthereumService: Sendable {
    static let gasLimitPercent = 50.0
    static let historyBlocks = 10

    let chain: EVMChain
    let provider: Provider<EthereumTarget>

    public init(
        chain: EVMChain,
        provider: Provider<EthereumTarget>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension EthereumService {
    
    func getGasLimit(from: String, to: String, value: String?, data: String?) async throws -> BigInt {
        do {
            let gasLimit = try await provider
                .request(.estimateGasLimit(from: from, to: to, value: value, data: data))
                .mapResultOrError(as: BigIntable.self).value
            return gasLimit == BigInt(21000) ? gasLimit : BigInt(gasLimit).increase(byPercentage: Self.gasLimitPercent)
        } catch let error {
            throw AnyError("Estimate gasLimit error: \(error.localizedDescription)")
        }
    }

    func getNonce(senderAddress: String) async throws -> Int {
        return try await provider
            .request(.transactionsCount(address: senderAddress))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value.asInt
    }

    func getChainId() async throws -> Int {
        if let networkId = Int(GemstoneConfig.shared.getChainConfig(chain: chain.chain.rawValue).networkId) {
            return networkId
        }
        throw AnyError("Unable to get chainId")
    }

    private func getMaxPriorityFeePerGas() async throws -> BigInt {
        try await provider
            .request(.maxPriorityFeePerGas)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }


    private func getBalance(address: String) async throws -> BigInt {
        try await provider.request(.balance(address: address))
           .mapResult(BigIntable.self).value
    }
}

// MARK: - ChainBalanceable

extension EthereumService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await getBalance(address: address)

        return AssetBalance(
            assetId: chain.chain.assetId,
            balance: Balance(available: balance)
        )
    }

    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        let requests = try tokenIds.map {
            EthereumTarget.call([
                "to": try $0.getTokenId(),
                "data": "0x70a08231000000000000000000000000\(address.remove0x)",
            ])
        }
        let balances = try await provider.request(.batch(requests: requests))
            .map(as: [JSONRPCResponse<BigIntable>].self)
            .map(\.result.value)
        
        return zip(tokenIds, balances).map {
            AssetBalance(assetId: $0, balance: Balance(available: $1))
        }
    }
    
    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        switch chain {
        case .smartChain:
            return try await SmartChainService(provider: provider).getStakeBalance(for: address)
        default:
            break
        }
        return .none
    }
}

// MARK: - ChainTransactionPreloadable

extension EthereumService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let fee = fee(input: input.feeInput)
        async let sequence = getNonce(senderAddress: input.senderAddress)
        async let chainId = getChainId()
        
        return try await TransactionPreload(
            sequence: sequence,
            chainId: chainId.asString,
            fee: fee,
            extra: .none
        )
    }
}

// MARK: - ChainBroadcastable

extension EthereumService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .mapOrError(
                as: JSONRPCResponse<String>.self,
                asError: JSONRPCError.self
            ).result
    }
}

// MARK: - ChainTransactionStateFetchable

extension EthereumService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transactionReceipt(id: request.id))
            .map(as: JSONRPCResponse<EthereumTransactionReciept>.self).result

        if transaction.status == "0x0" || transaction.status == "0x1"  {
            let state: TransactionState = switch transaction.status {
                case "0x0": .reverted
                case "0x1": .confirmed
                default: .confirmed
            }
            let gasUsed = try BigInt.fromHex(transaction.gasUsed)
            let effectiveGasPrice = try BigInt.fromHex(transaction.effectiveGasPrice)
            let l1Fee: BigInt = try {
                guard let fee = transaction.l1Fee else { return .zero }
                return try BigInt.fromHex(fee)
            }()
            let networkFee = gasUsed * effectiveGasPrice + l1Fee

            return TransactionChanges(
                state: state,
                changes: [.networkFee(networkFee)]
            )
        }

        return TransactionChanges(state: .pending)
    }
}

// MARK: - ChainSyncable

extension EthereumService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        return try await provider
            .request(.syncing)
            .map(as: JSONRPCResponse<Bool>.self).result.inverted
    }
}

// MARK: - ChainStakable

extension EthereumService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        switch chain {
        case .smartChain:
            return try await SmartChainService(provider: provider).getValidators(apr: 0)
        default:
            return []
        }
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        switch chain {
        case .smartChain:
            return try await SmartChainService(provider: provider).getStakeDelegations(address: address)
        default:
            return []
        }
    }
}

// MARK: - ChainTokenable

extension EthereumService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        guard let address = WalletCore.AnyAddress(string: tokenId, coin: chain.chain.coinType)?.description else {
            throw TokenValidationError.invalidTokenId
        }
        let assetId = AssetId(chain: chain.chain, tokenId: address)

        return try await ERC20Service(provider: provider).decode(assetId: assetId, address: address)
    }

    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.hasPrefix("0x") && Data(fromHex: tokenId) != nil && tokenId.count == 42
    }
}

// MARK: - ChainIDFetchable

extension EthereumService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        return try await provider
            .request(.chainId)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value.description
    }
}

// MARK: - ChainLatestBlockFetchable

extension EthereumService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        return try await provider
            .request(.latestBlock)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }
}

// MARK: - ChainAddressStatusFetchable

extension EthereumService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
