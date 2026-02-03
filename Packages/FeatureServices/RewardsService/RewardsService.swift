// Copyright (c). Gem Wallet. All rights reserved.

import AuthService
import Foundation
import GemAPI
import Preferences
import Primitives

public protocol RewardsServiceable: Sendable {
    func getRewards(wallet: Wallet) async throws -> Rewards
    func createReferral(wallet: Wallet, code: String) async throws -> Rewards
    func useReferralCode(wallet: Wallet, referralCode: String) async throws
    func generateReferralLink(code: String) -> URL
    func getRedemptionOption(code: String) async throws -> RewardRedemptionOption
    func redeem(wallet: Wallet, redemptionId: String) async throws -> RedemptionResult
}

public struct RewardsService: RewardsServiceable, Sendable {
    private let apiService: GemAPIRewardsService
    private let authService: AuthServiceable
    private let securePreferences: SecurePreferences

    public init(
        apiService: GemAPIRewardsService = GemAPIService.shared,
        authService: AuthServiceable,
        securePreferences: SecurePreferences = SecurePreferences()
    ) {
        self.apiService = apiService
        self.authService = authService
        self.securePreferences = securePreferences
    }

    public func getRewards(wallet: Wallet) async throws -> Rewards {
        let deviceId = try securePreferences.getDeviceId()
        return try await apiService.getRewards(deviceId: deviceId, walletId: wallet.id)
    }

    public func useReferralCode(wallet: Wallet, referralCode: String) async throws {
        let deviceId = try securePreferences.getDeviceId()
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: ReferralCode(code: referralCode))
        try await apiService.useReferralCode(deviceId: deviceId, walletId: wallet.id, request: request)
    }

    public func createReferral(wallet: Wallet, code: String) async throws -> Rewards {
        let deviceId = try securePreferences.getDeviceId()
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: ReferralCode(code: code))
        return try await apiService.createReferral(deviceId: deviceId, walletId: wallet.id, request: request)
    }

    public func generateReferralLink(code: String) -> URL {
        URL(string: "\(Constants.App.website)/join?code=\(code)")!
    }

    public func getRedemptionOption(code: String) async throws -> RewardRedemptionOption {
        let deviceId = try securePreferences.getDeviceId()
        return try await apiService.getRedemptionOption(deviceId: deviceId, code: code)
    }

    public func redeem(wallet: Wallet, redemptionId: String) async throws -> RedemptionResult {
        let deviceId = try securePreferences.getDeviceId()
        let auth = try await authService.getAuthPayload(wallet: wallet)
        let request = AuthenticatedRequest(auth: auth, data: RedemptionRequest(id: redemptionId))
        return try await apiService.redeem(deviceId: deviceId, walletId: wallet.id, request: request)
    }
}
