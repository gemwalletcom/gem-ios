// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import GemstonePrimitives
import NativeProviderService
import Primitives

public actor GatewayService: Sendable {
    let gateway: GemGateway

    public init(
        provider: NativeProvider
    ) {
        gateway = GemGateway(
            provider: provider,
            preferences: GemstonePreferences(namespace: "gateway"),
            securePreferences: GemstoneSecurePreferences(namespace: "gateway")
        )
    }
}

extension GatewayService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        try await EstimateFeeService().getFee(chain: chain, input: input)
    }

    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        try await EstimateFeeService().getFeeData(chain: chain, input: input)
    }
}

// MARK: - Balances

public extension GatewayService {
    func coinBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance {
        try await gateway.getBalanceCoin(chain: chain.rawValue, address: address).map()
    }

    func tokenBalance(chain: Primitives.Chain, address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway
            .getBalanceTokens(chain: chain.rawValue, address: address, tokenIds: tokenIds.compactMap(\.tokenId))
            .map { try $0.map() }
    }

    func getStakeBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance? {
        try await gateway.getBalanceStaking(chain: chain.rawValue, address: address)?.map()
    }
}

// MARK: - Transactions

extension GatewayService {
    public func transactionBroadcast(chain: Primitives.Chain, data: String, options: Primitives.BroadcastOptions = Primitives.BroadcastOptions(skipPreflight: false)) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain.rawValue, data: data, options: options.map())
    }

    func transactionStatus(chain: Primitives.Chain, request: TransactionStateRequest) async throws -> TransactionChanges {
        let update = try await gateway.getTransactionStatus(chain: chain.rawValue, request: request.map())
        let changes: [TransactionChange] = try update.changes.compactMap {
            switch $0 {
            case .hashChange(old: let old, new: let new):
                return TransactionChange.hashChange(old: old, new: new)
            case .metadata(let metadata):
                return TransactionChange.metadata(metadata.map())
            case .blockNumber(let number):
                return try TransactionChange.blockNumber(Int.from(string: number))
            case .networkFee(let fee):
                return try TransactionChange.networkFee(BigInt.from(string: fee))
            }
        }
        return try TransactionChanges(
            state: TransactionState(id: update.state),
            changes: changes
        )
    }
}

// MARK: - Account

public extension GatewayService {
    func utxos(chain: Primitives.Chain, address: String) async throws -> [UTXO] {
        try await gateway.getUtxos(chain: chain.rawValue, address: address).map {
            try $0.map()
        }
    }
}

// TransactionPreload

// MARK: - State

public extension GatewayService {
    func chainId(chain: Primitives.Chain) async throws -> String {
        try await gateway.getChainId(chain: chain.rawValue)
    }

    func latestBlock(chain: Primitives.Chain) async throws -> BigInt {
        try await gateway.getBlockNumber(chain: chain.rawValue).asBigInt
    }

    func feeRates(chain: Primitives.Chain, input: TransferDataType) async throws -> [FeeRate] {
        try await gateway.getFeeRates(chain: chain.rawValue, input: input.map()).map { try $0.map() }
    }

    func nodeStatus(chain: Primitives.Chain, url: String) async throws -> Primitives.NodeStatus {
        try await gateway.getNodeStatus(chain: chain.rawValue, url: url).map()
    }
}

// MARK: - Token

public extension GatewayService {
    func tokenData(chain: Primitives.Chain, tokenId: String) async throws -> Asset {
        try await gateway.getTokenData(chain: chain.rawValue, tokenId: tokenId).map()
    }

    func isTokenAddress(chain: Primitives.Chain, tokenId: String) async throws -> Bool {
        try await gateway.getIsTokenAddress(chain: chain.rawValue, tokenId: tokenId)
    }
}

// MARK: - Transaction Preload

public extension GatewayService {
    func transactionPreload(chain: Primitives.Chain, input: TransactionPreloadInput) async throws -> TransactionLoadMetadata {
        try await gateway.getTransactionPreload(chain: chain.rawValue, input: input.map()).map()
    }

    func transactionLoad(chain: Primitives.Chain, input: GemTransactionLoadInput) async throws -> TransactionData {
        try await gateway.getTransactionLoad(chain: chain.rawValue, input: input, provider: self).map()
    }
}

// MARK: - Staking

public extension GatewayService {
    func validators(chain: Primitives.Chain) async throws -> [DelegationValidator] {
        try await gateway.getStakingValidators(chain: chain.rawValue, apy: nil)
            .map { try $0.map() }
    }

    func delegations(chain: Primitives.Chain, address: String) async throws -> [DelegationBase] {
        try await gateway.getStakingDelegations(chain: chain.rawValue, address: address)
            .map { try $0.map() }
    }
}

// MARK: - Perpetual

public extension GatewayService {
    func getPositions(chain: Primitives.Chain, address: String) async throws -> PerpetualPositionsSummary {
        try await gateway.getPositions(chain: chain.rawValue, address: address).map()
    }

    func getPerpetualsData(chain: Primitives.Chain) async throws -> [PerpetualData] {
        try await gateway.getPerpetualsData(chain: chain.rawValue).map {
            try $0.map()
        }
    }

    func getCandlesticks(chain: Primitives.Chain, symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        try await gateway.getCandlesticks(chain: chain.rawValue, symbol: symbol, period: period.rawValue).map {
            try $0.map()
        }
    }
}

public extension GatewayService {
    func getAddressStatus(chain: Primitives.Chain, address: String) async throws -> [Primitives.AddressStatus] {
        try await gateway.getAddressStatus(chain: chain.rawValue, address: address).map { $0.map() }
    }
}
