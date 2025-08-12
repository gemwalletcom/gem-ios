// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Formatters
import Primitives
import SwiftHTTPClient

public struct HyperCoreService: Sendable {
    let chain: Primitives.Chain
    let provider: Provider<HypercoreProvider>
    let cacheService: HyperCoreCacheService
    
    private static let defaultConfig = HyperCoreServiceConfig(
        builderAddress: "0x0d9dab1a248f63b0a48965ba8435e4de7497a3dc",
        referralCode: "GEMWALLET",
        maxBuilderFeeBps: 45
    )
    
    public let config: HyperCoreServiceConfig
    
    public static var builderAddress: String {
        defaultConfig.builderAddress
    }
    
    public static var referralCode: String {
        defaultConfig.referralCode
    }
    
    public static var maxBuilderFeeBps: Int {
        defaultConfig.maxBuilderFeeBps
    }
    
    public init(
        chain: Primitives.Chain = .hyperCore,
        provider: Provider<HypercoreProvider>,
        cacheService: BlockchainCacheService,
        config: HyperCoreServiceConfig? = nil
    ) {
        self.chain = chain
        self.provider = provider
        self.config = config ?? Self.defaultConfig
        self.cacheService = HyperCoreCacheService(
            cacheService: cacheService,
            preferences: HyperCoreSecurePreferences()
        )
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
    
    func getExtraAgents(user: String) async throws -> [HypercoreAgentSession] {
        try await self.provider
            .request(.extraAgents(user: user))
            .map(as: [HypercoreAgentSession].self)
    }
    
    func getBuilderFee(address: String, builder: String) async throws -> Int {
        try await self.provider
            .request(.builderFee(address: address, builder: builder))
            .map(as: Int.self)
    }
    
    func getUserFees(user: String) async throws -> HypercoreUserFee {
        try await self.provider
            .request(.userFees(user: user))
            .map(as: HypercoreUserFee.self)
    }
    
    func getSpotBalances(user: String) async throws -> HypercoreBalances {
        try await provider
            .request(.spotClearinghouseState(user: user))
            .map(as: HypercoreBalances.self)
    }
    
    func getSpotMetadata() async throws -> HypercoreTokens {
        try await provider
            .request(.spotMetaAndAssetCtxs)
            .map(as: HypercoreTokens.self)
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
        let balances = try await getSpotBalances(user: address).balances
        guard let coin = balances.first(where: { $0.token == 150 }) else {
            throw AnyError("")
        }
        return AssetBalance(
            assetId: AssetId(chain: chain),
            balance: Balance(available: try BigInt.from(coin.total, decimals: 18))
        )
    }

    func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        // let balances = try await getSpotBalances(user: address).balances
        // let tokens = try await getSpotMetadata().tokens
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
        
        // Try to parse as order response first to get oid
        if let orderResult = try? response.map(as: HypercoreOrderResponse.self),
           orderResult.status == "ok",
           let responseData = orderResult.response,
           let orderData = responseData.data,
           let statuses = orderData.statuses,
           let firstStatus = statuses.first {
            
            if let filled = firstStatus.filled {
                return String(filled.oid)
            } else if let resting = firstStatus.resting {
                return String(resting.oid)
            } else if let error = firstStatus.error {
                throw AnyError(error)
            }
        }
        
        // Fallback to regular response handling
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
        return ""
    }
}

// MARK: - ChainLatestBlockFetchable

public extension HyperCoreService {
    func getLatestBlock() async throws -> BigInt {
        return BigInt(1)
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
        async let approveAgentRequired = cacheService.needsAgentApproval(walletAddress: input.senderAddress) {
            try await getExtraAgents(user: input.senderAddress)
        }
        
        async let approveReferralRequired = cacheService.needsReferralApproval(address: input.senderAddress) {
            try await getReferral(address: input.senderAddress)
        }
        
        async let approveBuilderRequired = cacheService.needsBuilderFeeApproval(address: input.senderAddress) {
            try await getBuilderFee(address: input.senderAddress, builder: Self.builderAddress)
        }
        
        async let totalFeeTenthsBps = cacheService.getUserFeeRate(address: input.senderAddress) {
            try await getUserFees(user: input.senderAddress)
        }
        
        let (agentRequired, referralRequired, builderRequired, feeRate) = try await (approveAgentRequired, approveReferralRequired, approveBuilderRequired, totalFeeTenthsBps)
        
        switch input.type {
        case .perpetual(_, let type):
            let fiatValue = switch type {
            case .open(let data): data.fiatValue
            case .close(let data): data.fiatValue
            }
            let feeAmount = Int(fiatValue * Double(feeRate * 2) * 10)
            
            return TransactionData(
                data: .hyperliquid(
                    SigningData.Hyperliquid(
                        approveAgentRequired: agentRequired,
                        approveReferralRequired: referralRequired,
                        approveBuilderRequired: builderRequired,
                        builderFeeBps: feeRate
                    )
                ),
                fee: .init(fee: BigInt(feeAmount), gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero)
            )
        case .withdrawal:
            return TransactionData(
                data: .hyperliquid(
                    SigningData.Hyperliquid(
                        approveAgentRequired: false,
                        approveReferralRequired: false,
                        approveBuilderRequired: false,
                        builderFeeBps: 0
                    )
                ),
                fee: .init(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero)
            )
        default:
            throw AnyError.notImplemented
        }
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
        guard let oid = UInt64(request.id) else {
            return TransactionChanges(state: .pending)
        }
        
        let startTime = Int((request.createdAt.timeIntervalSince1970 - 5) * 1000)
        
        let fills = try await provider
            .request(.userFillsByTime(user: request.senderAddress, startTime: startTime))
            .map(as: [HypercorePerpetualFill].self)
        
        guard let matchingFill = fills.first(where: { $0.oid == oid }) else {
            return TransactionChanges(state: .pending)
        }
        
        return TransactionChanges(
            state: .confirmed,
            changes: [
                .hashChange(old: request.id, new: matchingFill.hash),
                .metadata(TransactionMetadata.perpetual(
                    TransactionPerpetualMetadata(
                        pnl: try Double.from(string: matchingFill.closedPnl),
                        price: try Double.from(string: matchingFill.px)
                    )
                ))
            ]
        )
    }
}

extension HypercoreErrorResponse: LocalizedError {
    public var errorDescription: String? {
        response
    }
}
