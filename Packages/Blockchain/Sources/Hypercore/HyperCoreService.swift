// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Formatters
import Primitives
import SwiftHTTPClient
import WalletCorePrimitives

public struct HyperCoreService: Sendable {
    let chain: Primitives.Chain
    let provider: Provider<HypercoreProvider>
    let gateway: GatewayService
    let cacheService: HyperCoreCacheService
    public let config: HyperCoreConfig
    
    public init(
        chain: Primitives.Chain = .hyperCore,
        provider: Provider<HypercoreProvider>,
        gateway: GatewayService,
        cacheService: BlockchainCacheService,
        config: HyperCoreConfig
    ) {
        self.chain = chain
        self.provider = provider
        self.gateway = gateway
        self.config = config
        self.cacheService = HyperCoreCacheService(
            cacheService: cacheService,
            preferences: HyperCoreSecurePreferences(),
            config: config
        )
    }
    
    public static func feeRate(_ tenthsBps: Int) -> String {
        String(format: "%g%%", Double(tenthsBps) * 0.001)
    }
}

// MARK: - Business Logic

public extension HyperCoreService {
    
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
    
}

// MARK: - ChainServiceable

extension HyperCoreService: ChainServiceable {}

public extension HyperCoreService {
    func preload(input: TransactionPreloadInput) async throws -> TransactionLoadMetadata {
        return .none
    }
}

// MARK: - ChainAddressStatusFetchable

public extension HyperCoreService {
    func getAddressStatus(address: String) async throws -> [AddressStatus] {
        return []
    }
}

// MARK: - ChainBalanceable

public extension HyperCoreService {
    func coinBalance(for address: String) async throws -> AssetBalance {
        try await gateway.coinBalance(chain: chain, address: address)
    }

    func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        try await gateway.tokenBalance(chain: chain, address: address, tokenIds: tokenIds)
    }

    func getStakeBalance(for address: String) async throws -> AssetBalance? {
        try await gateway.getStakeBalance(chain: chain, address: address)
    }
}

// MARK: - ChainBroadcastable

public extension HyperCoreService {
    func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain, data: data)
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
        try await gateway.validators(chain: chain)
    }

    func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        try await gateway.delegations(chain: chain, address: address)
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
            try await getBuilderFee(address: input.senderAddress, builder: config.builderAddress)
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


// MARK: - ChainTransactionStateFetchable

public extension HyperCoreService {
    func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        try await gateway.transactionStatus(chain: chain, request: request)
    }
}
