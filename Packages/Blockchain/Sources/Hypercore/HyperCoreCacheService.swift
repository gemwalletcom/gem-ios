// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct HyperCoreCacheService: Sendable {
    private let cacheService: BlockchainCacheService
    private let preferences: HyperCoreSecurePreferences
    private let config: HyperCoreConfig

    private static let referralApprovedKey = "referral_approved"
    private static let builderFeeApprovedKey = "builder_fee_approved"
    private static let agentValidUntilKey = "agent_valid_until"
    private static let userFeesKey = "user_fees"
    private static let userFeesCacheTimeSeconds = 86_400 * 7
    
    public init(
        cacheService: BlockchainCacheService,
        preferences: HyperCoreSecurePreferences,
        config: HyperCoreConfig
    ) {
        self.cacheService = cacheService
        self.preferences = preferences
        self.config = config
    }
    
    public func needsAgentApproval(walletAddress: String, checker: () async throws -> [HypercoreAgentSession]) async throws -> Bool {
        guard let agentAddress = try? preferences.get(walletAddress: walletAddress)?.address else { return true }

        let currentTime = Int(Date().timeIntervalSince1970)
        if let value = cacheService.getInt(address: agentAddress, key: Self.agentValidUntilKey), currentTime < value {
            return false
        }
        let agents = try await checker()
        
        if let agent = agents.first(where: { $0.address.lowercased() == agentAddress.lowercased() }) {
            let validUntil = Int(agent.validUntil / 1000)
            cacheService.setInt(validUntil, address: agentAddress, key: Self.agentValidUntilKey)
            return currentTime >= validUntil
        }
        
        return true
    }
    
    public func needsReferralApproval(address: String, checker: () async throws -> HypercoreReferral) async throws -> Bool {
        try await checkApproval(address: address, key: Self.referralApprovedKey) {
            let referral = try await checker()
            return referral.referredBy == .none && (Double(referral.cumVlm) ?? 0) < 10_000
        }
    }
    
    public func needsBuilderFeeApproval(address: String, checker: () async throws -> Int) async throws -> Bool {
        try await checkApproval(address: address, key: Self.builderFeeApprovedKey) {
            let fee = try await checker()
            return config.maxBuilderFeeBps > fee
        }
    }
    
    public func getUserFeeRate(address: String, fetcher: () async throws -> HypercoreUserFee) async throws -> Int {
        let ttl = TimeInterval(Self.userFeesCacheTimeSeconds)
        
        if let cachedRate = cacheService.getInt(address: address, key: Self.userFeesKey, ttl: ttl) {
            return cachedRate
        }
        
        let userFees = try await fetcher()
        let userCrossRate = try Double.from(string: userFees.userCrossRate)
        let referralDiscountPercentage = try Double.from(string: userFees.activeReferralDiscount)
        let effectiveRate = userCrossRate * (1 - referralDiscountPercentage)
        let rateInTenthsBps = Int(effectiveRate * 100000)
        
        cacheService.setInt(rateInTenthsBps, address: address, key: Self.userFeesKey, ttl: ttl)
        
        return rateInTenthsBps
    }
    
    private func checkApproval(address: String, key: String, needsApprovalChecker: () async throws -> Bool) async rethrows -> Bool {
        if cacheService.hasKey(address, key: key) {
            return false
        }
        
        let needsApproval = try await needsApprovalChecker()
        
        if !needsApproval {
            cacheService.setBool(true, address: address, key: key)
        }
        
        return needsApproval
    }
}
