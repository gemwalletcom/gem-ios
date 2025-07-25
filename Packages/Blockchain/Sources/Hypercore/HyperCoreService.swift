// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct HyperCoreService: Sendable {
    
    let chain: Primitives.Chain
    let provider: Provider<HypercoreProvider>
    
    public init(
        chain: Primitives.Chain = .hyperCore,
        provider: Provider<HypercoreProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension HyperCoreService {
    
    public func getPositions(user: String) async throws -> HypercoreAssetPositions {
        return try await provider
            .request(.clearinghouseState(user: user))
            .map(as: HypercoreAssetPositions.self)
    }
    
    public func getMetadata() async throws -> HypercoreMetadataResponse {
        return try await provider
            .request(.metaAndAssetCtxs)
            .map(as: HypercoreMetadataResponse.self)
    }
    
    public func getCandlesticks(coin: String, interval: String = "1m", startTime: Int, endTime: Int) async throws -> [HypercoreCandlestick] {
        return try await provider
            .request(.candleSnapshot(coin: coin, interval: interval, startTime: startTime, endTime: endTime))
            .map(as: [HypercoreCandlestick].self)
    }
}

// MARK: - ChainServiceable

extension HyperCoreService: ChainServiceable {}

// MARK: - ChainAddressStatusFetchable

extension HyperCoreService {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        return []
    }
}

// MARK: - ChainBalanceable

extension HyperCoreService {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        AssetBalance(assetId: AssetId(chain: chain), balance: Balance(available: .zero))
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        return []
    }
    
    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        return nil
    }
}

// MARK: - ChainBroadcastable

extension HyperCoreService {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        throw AnyError("Not implemented")
    }
}

// MARK: - ChainFeeRateFetchable

extension HyperCoreService {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 0))
        ]
    }
}

// MARK: - ChainIDFetchable

extension HyperCoreService {
    public func getChainID() async throws -> String {
        return "42161" // Arbitrum chain ID
    }
}

// MARK: - ChainLatestBlockFetchable

extension HyperCoreService {
    public func getLatestBlock() async throws -> BigInt {
        return BigInt(0)
    }
}

// MARK: - ChainStakable

extension HyperCoreService {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }
    
    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        return []
    }
}

// MARK: - ChainSyncable

extension HyperCoreService {
    public func getInSync() async throws -> Bool {
        return true
    }
}

// MARK: - ChainTokenable

extension HyperCoreService {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        return false
    }
}

// MARK: - ChainTransactionDataLoadable

extension HyperCoreService {
    public func load(input: TransactionInput) async throws -> TransactionData {
        throw AnyError("Not implemented")
    }
}

// MARK: - ChainTransactionPreloadable

extension HyperCoreService {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        throw AnyError("Not implemented")
    }
}

// MARK: - ChainTransactionStateFetchable

extension HyperCoreService {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        throw AnyError("Not implemented")
    }
}
