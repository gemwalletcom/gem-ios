// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Keychain
import Primitives
import SwiftHTTPClient

public struct HyperCoreService: Sendable {
    let chain: Primitives.Chain
    let provider: Provider<HypercoreProvider>
    let keychain: Keychain
    
    public static let agentAddressKey: String = "hyperliquid_agent_address"
    public static let agentPrivateKey: String = "hyperliquid_agent_private_key"
    public static let feeRateBps = 10
    public static let maxFeeRateBps = 50
    public static let builderAddress = "0x0d9dab1a248f63b0a48965ba8435e4de7497a3dc"
    public static let referralCode = "GEMWALLET"
    
    public init(
        chain: Primitives.Chain = .hyperCore,
        provider: Provider<HypercoreProvider>,
        keychain: Keychain = KeychainDefault()
    ) {
        self.chain = chain
        self.provider = provider
        self.keychain = keychain
    }
    
    public static func feeRate(_ tenthsBps: Int) -> String {
        String(format: "%g%%", Double(tenthsBps) * 0.001)
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

    func getCandlesticks(coin: String, interval: String, startTime: Int, endTime: Int) async throws -> [HypercoreCandlestick] {
        return try await provider
            .request(.candleSnapshot(coin: coin, interval: interval, startTime: startTime, endTime: endTime))
            .map(as: [HypercoreCandlestick].self)
    }
    
    func getUserRole(address: String) async throws -> HypercoreUserRole {
        try await self.provider
            .request(.userRole(address: address))
            .map(as: HypercoreUserRole.self)
    }
    
    func getReferral(address: String) async throws -> HypercoreReferral {
        try await self.provider
            .request(.referral(address: address))
            .map(as: HypercoreReferral.self)
    }
    
    func getBuilderFee(address: String, builder: String) async throws -> Int {
        try await self.provider
            .request(.builderFee(address: address, builder: builder))
            .map(as: Int.self)
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
        let response = try await self.provider.request(.broadcast(data: data))
        let result = try response.map(as: HypercoreResponse.self)
        
        switch result.status {
        case "ok": return data
        case "err":
            throw try response.map(as: HypercoreErrorResponse.self)
        default:
            throw ChainServiceErrors.broadcastError(chain)
        }
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
        let referral = try await getReferral(address: input.senderAddress)
        let builderFee = try await getBuilderFee(address: input.senderAddress, builder: Self.builderAddress)
        
        var approveAgentRequired: Bool = true
        
        if let address = try keychain.get(Self.agentAddressKey) {
            let role = try await getUserRole(address: address)
            approveAgentRequired = role.role != "agent"
        }
        
        let approveReferralRequired = referral.referredBy == .none && (Double(referral.cumVlm) ?? 0) < 10_000
        let approveBuilderRequired = builderFee < Self.maxFeeRateBps
        
        return TransactionData(
            data: .hyperliquid(
                SigningData.Hyperliquid(
                    approveAgentRequired: approveAgentRequired,
                    approveReferralRequired: approveReferralRequired,
                    approveBuilderRequired: approveBuilderRequired,
                    timestamp: Date.getTimestampInMs()
                )
            ),
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

extension HypercoreErrorResponse: LocalizedError {
    public var errorDescription: String? {
        response
    }
}
