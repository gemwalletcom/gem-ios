// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AuthService

public struct AuthServiceMock: AuthServiceable, Sendable {
    public var authPayloadResult: Result<AuthPayload, Error>

    public init(
        authPayloadResult: Result<AuthPayload, Error> = .success(.mock())
    ) {
        self.authPayloadResult = authPayloadResult
    }

    public func getAuthPayload(wallet: Wallet) async throws -> AuthPayload {
        try authPayloadResult.get()
    }
}

public extension AuthService {
    static func mock() -> AuthServiceMock {
        AuthServiceMock()
    }
}

public extension AuthPayload {
    static func mock(
        deviceId: String = "test-device-id",
        chain: Chain = .ethereum,
        address: String = "0x1234567890abcdef1234567890abcdef12345678",
        nonce: String = "test-nonce",
        signature: String = "0xsignature"
    ) -> AuthPayload {
        AuthPayload(
            deviceId: deviceId,
            chain: chain,
            address: address,
            nonce: nonce,
            signature: signature
        )
    }
}
