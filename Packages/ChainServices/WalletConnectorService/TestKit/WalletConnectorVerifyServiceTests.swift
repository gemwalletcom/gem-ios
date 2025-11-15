// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import WalletConnectorService
@preconcurrency import ReownWalletKit

struct WalletConnectorVerifyServiceTests {
    let service = WalletConnectorVerifyService()
    let metadata = WalletConnectionSessionAppMetadata(
        name: "Uniswap",
        description: "Swap tokens",
        url: "https://app.uniswap.org",
        icon: "https://app.uniswap.org/icon.png"
    )

    @Test
    func noVerifyContext() {
        #expect(service.validateOrigin(metadata: metadata, verifyContext: nil) == .unknown)
    }

    @Test
    func scamValidation() {
        let context = VerifyContext(origin: "https://malicious.com", validation: .scam)
        #expect(service.validateOrigin(metadata: metadata, verifyContext: context) == .malicious)
    }

    @Test
    func validMatchingOrigin() {
        let context = VerifyContext(origin: "https://app.uniswap.org", validation: .valid)
        #expect(service.validateOrigin(metadata: metadata, verifyContext: context) == .verified)
    }
}
