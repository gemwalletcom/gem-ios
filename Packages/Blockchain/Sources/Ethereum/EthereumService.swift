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
    let provider: Provider<EthereumProvider>

    public init(
        chain: EVMChain,
        provider: Provider<EthereumProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension EthereumService {
    // MARK: - Internal
    static func decodeABI(hexString: String) -> String? {
        // WalletCore decodeValue doesn't work as expected, need to drop first offset byte
        guard
            let data = Data(fromHex: hexString),
            data.count > 32
        else {
            return nil
        }
        return EthereumAbiValue.decodeValue(input: data.dropFirst(32), type: "string")
    }

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

    private func getTokenBalance(contract: String, address: String) async throws -> BigInt {
        let data = "0x70a08231000000000000000000000000\(address.remove0x)"
        let params = [
            "to": contract,
            "data": data,
        ]
        return try await provider
            .request(.call(params))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }

    private func getERC20Decimals(contract: String) async throws -> BigInt {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "decimals"))
        let params = [
            "to": contract,
            "data": data.hexString.append0x,
        ]
        return try await provider
            .request(.call(params))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }

    private func getERC20Name(contract: String) async throws -> String {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "name"))
        let params = [
            "to": contract,
            "data": data.hexString.append0x,
        ]
        let response = try await provider
            .request(.call(params))
            .map(as: JSONRPCResponse<String>.self).result
        return Self.decodeABI(hexString: response) ?? ""
    }

    private func getERC20Symbol(contract: String) async throws -> String {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "symbol")).hexString.append0x
        let params = [
            "to": contract,
            "data": data,
        ]
        let response = try await provider
            .request(.call(params))
            .map(as: JSONRPCResponse<String>.self).result
        return Self.decodeABI(hexString: response) ?? ""
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
        var result: [AssetBalance] = []
        for tokenId in tokenIds {
            let balance = try await getTokenBalance(contract: tokenId.tokenId ?? "", address: address)
            result.append(AssetBalance(assetId: tokenId, balance: Balance(available: balance)))
        }
        return result
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

        async let getName = getERC20Name(contract: address)
        async let getSymbol = getERC20Symbol(contract: address)
        async let getDecimals = getERC20Decimals(contract: address)

        let (name, symbol, decimals) = try await (getName, getSymbol, getDecimals)

        return Asset(
            id: assetId,
            name: name,
            symbol: symbol,
            decimals: decimals.asInt.asInt32,
            type: try assetId.getAssetType()
        )
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
