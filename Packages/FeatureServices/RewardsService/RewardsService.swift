// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import AuthService

public protocol RewardsServiceable: Sendable {
    func getRewards(wallet: Wallet) async throws -> Rewards
    func createReferral(wallet: Wallet, code: String) async throws -> Rewards
    func useReferralCode(wallet: Wallet, referralCode: String) async throws
    func generateReferralLink(code: String) -> URL
    func redeem(wallet: Wallet, redemptionId: String) async throws -> RedemptionResult
}

public struct RewardsService: RewardsServiceable, Sendable {
    private let apiService: GemAPIRewardsService
    private let authService: AuthServiceable

    public init(
        apiService: GemAPIRewardsService = GemAPIService.shared,
        authService: AuthServiceable
    ) {
        self.apiService = apiService
        self.authService = authService
    }

    public func getRewards(wallet: Wallet) async throws -> Rewards {
        let account = try wallet.account(for: .ethereum)
        return try await apiService.getRewards(address: account.address)
    }

    public func useReferralCode(wallet: Wallet, referralCode: String) async throws {
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: ReferralCode(code: referralCode))
        try await apiService.useReferralCode(request: request)
    }

    public func createReferral(wallet: Wallet, code: String) async throws -> Rewards {
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: ReferralCode(code: code))
        return try await apiService.createReferral(request: request)
    }

    public func generateReferralLink(code: String) -> URL {
        URL(string: "\(Constants.App.website)/join?code=\(code)")!
    }

    public func redeem(wallet: Wallet, redemptionId: String) async throws -> RedemptionResult {
        let account = try wallet.account(for: .ethereum)
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: RedemptionRequest(id: redemptionId))
        return try await apiService.redeem(address: account.address, request: request)
    }
}
