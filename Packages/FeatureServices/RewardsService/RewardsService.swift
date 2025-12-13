// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Keystore
import Gemstone
import WalletCore
import Preferences

public protocol RewardsServiceable: Sendable {
    func getRewards(wallet: Primitives.Wallet) async throws -> Rewards
    func createReferral(wallet: Primitives.Wallet, code: String) async throws -> Rewards
    func useReferralCode(wallet: Primitives.Wallet, referralCode: String) async throws
    func generateReferralLink(code: String) -> URL
}

public struct RewardsService: RewardsServiceable, Sendable {
    private let apiService: GemAPIRewardsService
    private let keystore: any Keystore
    private let securePreferences: SecurePreferences

    public init(
        apiService: GemAPIRewardsService = GemAPIService.shared,
        keystore: any Keystore,
        securePreferences: SecurePreferences = SecurePreferences()
    ) {
        self.apiService = apiService
        self.keystore = keystore
        self.securePreferences = securePreferences
    }

    public func getRewards(wallet: Primitives.Wallet) async throws -> Rewards {
        let account = try wallet.account(for: .ethereum)
        return try await apiService.getRewards(address: account.address)
    }

    public func useReferralCode(wallet: Primitives.Wallet, referralCode: String) async throws {
        let deviceId = try securePreferences.getDeviceId()
        let signedMessage = try await signAuthMessage(wallet: wallet)
        let request = RewardsReferralRequest(
            deviceId: deviceId,
            address: signedMessage.address,
            message: signedMessage.message,
            signature: signedMessage.signature,
            code: referralCode
        )
        try await apiService.useReferralCode(request: request)
    }

    public func createReferral(wallet: Primitives.Wallet, code: String) async throws -> Rewards {
        let deviceId = try securePreferences.getDeviceId()
        let signedMessage = try await signAuthMessage(wallet: wallet)
        let request = RewardsReferralRequest(
            deviceId: deviceId,
            address: signedMessage.address,
            message: signedMessage.message,
            signature: signedMessage.signature,
            code: code
        )
        return try await apiService.createReferral(request: request)
    }

    public func generateReferralLink(code: String) -> URL {
        URL(string: "\(Constants.App.website)/join?code=\(code)")!
    }

    private func signAuthMessage(wallet: Primitives.Wallet) async throws -> (address: String, message: String, signature: String) {
        let account = try wallet.account(for: .ethereum)
        let authMessage = Gemstone.createReferralAuthMessage(address: account.address, chainId: 1)

        let signature = try await keystore.sign(hash: Data(authMessage.hash), wallet: wallet, chain: .ethereum)

        return (account.address, authMessage.message, signature.hexString.append0x)
    }
}
