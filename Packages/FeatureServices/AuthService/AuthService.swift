// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Keystore
import Gemstone
import GemstonePrimitives
import Preferences

public protocol AuthServiceable: Sendable {
    func getAuthPayload(wallet: Wallet) async throws -> AuthPayload
}

public struct AuthService: AuthServiceable, Sendable {
    private let apiService: GemAPIAuthService
    private let keystore: any Keystore
    private let securePreferences: SecurePreferences

    public init(
        apiService: GemAPIAuthService = GemAPIService.shared,
        keystore: any Keystore,
        securePreferences: SecurePreferences = SecurePreferences()
    ) {
        self.apiService = apiService
        self.keystore = keystore
        self.securePreferences = securePreferences
    }

    public func getAuthPayload(wallet: Wallet) async throws -> AuthPayload {
        let deviceId = try securePreferences.getDeviceId()
        let chain = Chain.ethereum
        let account = try wallet.account(for: chain)

        let authNonce = try await apiService.getAuthNonce(deviceId: deviceId)
        let authMessage = Gemstone.createAuthMessage(chain: chain.rawValue, address: account.address, authNonce: authNonce.map())
        let signature = try await keystore.sign(hash: Data(authMessage.hash), wallet: wallet, chain: chain)

        return AuthPayload(
            deviceId: deviceId,
            chain: chain,
            address: account.address,
            nonce: authNonce.nonce,
            signature: signature.hexString.append0x
        )
    }
}
