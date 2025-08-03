// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keychain

public struct HyperCoreCacheService: Sendable {
    private let cacheService: BlockchainCacheService
    private let keychain: Keychain
    
    // Cache keys
    private static let referralApprovedKey = "referral_approved"
    private static let builderFeeApprovedKey = "builder_fee_approved"
    
    public init(cacheService: BlockchainCacheService, keychain: Keychain = KeychainDefault()) {
        self.cacheService = cacheService
        self.keychain = keychain
    }
    
    public func needsAgentApproval(walletAddress: String, checker: (String) async throws -> HypercoreUserRole) async throws -> Bool {
        let agentAddressKey = "\(HyperCoreService.agentAddressKey)_\(walletAddress)"
        guard let address = try? keychain.get(agentAddressKey) else { return true }
        let role = try await checker(address)
        return role.role != "agent"
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
            return HyperCoreService.builderFeeBps > fee
        }
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
