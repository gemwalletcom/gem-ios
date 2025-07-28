// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Keychain
import Primitives
import SwiftHTTPClient

let HLAgentName: String = "GemWallet"
let HLAgentAddress: String = "HyperliquidAgentAddress"
let HLAgentKey: String = "HyperliquidAgentKey"

public struct HyperCoreService: Sendable {
    let chain: Primitives.Chain
    let provider: Provider<HypercoreProvider>
    let keychain: KeychainDefault

    public init(
        chain: Primitives.Chain = .hyperCore,
        provider: Provider<HypercoreProvider>
    ) {
        self.chain = chain
        self.provider = provider
        self.keychain = KeychainDefault()
    }
}

// MARK: - Business Logic

public extension HyperCoreService {
    func getPositions(user: String) async throws -> HypercoreAssetPositions {
        return try await provider
            .request(.clearinghouseState(user: user))
            .map(as: HypercoreAssetPositions.self)
    }

    func getMetadata() async throws -> HypercoreMetadataResponse {
        return try await provider
            .request(.metaAndAssetCtxs)
            .map(as: HypercoreMetadataResponse.self)
    }

    func getCandlesticks(coin: String, interval: String = "1m", startTime: Int, endTime: Int) async throws -> [HypercoreCandlestick] {
        return try await provider
            .request(.candleSnapshot(coin: coin, interval: interval, startTime: startTime, endTime: endTime))
            .map(as: [HypercoreCandlestick].self)
    }

    func getAgentKey() async throws -> String {
        if let key = try keychain.get(HLAgentKey) {
            return key
        }
        let newKey = try SecureRandom.generateKey()
        try keychain.set(newKey, key: HLAgentKey)
        return newKey
    }
}

// MARK: - ChainServiceable

extension HyperCoreService: ChainServiceable {}

// MARK: - ChainAddressStatusFetchable

public extension HyperCoreService {
    func getAddressStatus(address: String) async throws -> [AddressStatus] {
        return []
    }
}

// MARK: - ChainBalanceable

public extension HyperCoreService {
    func coinBalance(for address: String) async throws -> AssetBalance {
        AssetBalance(assetId: AssetId(chain: chain), balance: Balance(available: .zero))
    }

    func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        return []
    }

    func getStakeBalance(for address: String) async throws -> AssetBalance? {
        return nil
    }
}

// MARK: - ChainBroadcastable

public extension HyperCoreService {
    func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        //TODO: Perpetual. Handle different responses based on the action
        try await self.provider.request(.broadcast(data: data)).map(as: String.self)
    }
}

// MARK: - ChainFeeRateFetchable

public extension HyperCoreService {
    func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 0))
        ]
    }
}

// MARK: - ChainIDFetchable

public extension HyperCoreService {
    func getChainID() async throws -> String {
        return "42161" // Arbitrum chain ID
    }
}

// MARK: - ChainLatestBlockFetchable

public extension HyperCoreService {
    func getLatestBlock() async throws -> BigInt {
        return BigInt(0)
    }
}

// MARK: - ChainStakable

public extension HyperCoreService {
    func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        return []
    }
}

// MARK: - ChainSyncable

public extension HyperCoreService {
    func getInSync() async throws -> Bool {
        return true
    }
}

// MARK: - ChainTokenable

public extension HyperCoreService {
    func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not implemented")
    }

    func getIsTokenAddress(tokenId: String) -> Bool {
        return false
    }
}

// MARK: - ChainTransactionDataLoadable

public extension HyperCoreService {
    func load(input: TransactionInput) async throws -> TransactionData {
        TransactionData(
            fee: .init(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero)
        )
    }
}

// MARK: - ChainTransactionPreloadable

public extension HyperCoreService {
    func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        TransactionPreload()
    }
}

// MARK: - ChainTransactionStateFetchable

public extension HyperCoreService {
    func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        TransactionChanges(state: .confirmed)
    }
}
