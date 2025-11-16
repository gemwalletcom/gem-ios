// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import struct Gemstone.SiweMessage
@testable import WalletConnector

struct SiweMessageViewModelTests {

    @Test
    func trimsStatementAndFiltersResources() {
        let message = SiweMessage(
            domain: "login.xyz",
            scheme: "https",
            address: "0x6dD7802E6d44bE89a789C4bD60bD511B68F41c7c",
            statement: "  Sign in  ",
            uri: "https://login.xyz",
            version: "1",
            chainId: 1,
            nonce: "nonceabcd",
            issuedAt: "2024-04-01T12:00:00Z",
            expirationTime: nil,
            notBefore: nil,
            requestId: nil,
            resources: ["https://example.com/terms", " "]
        )

        let viewModel = SiweMessageViewModel(message: message)
        #expect(viewModel.domainText == "login.xyz")
        #expect(viewModel.websiteText == "https://login.xyz")
        #expect(viewModel.addressText == "0x6dD7802E6d44bE89a789C4bD60bD511B68F41c7c")
        #expect(viewModel.statementText == "Sign in")
        #expect(viewModel.resources == ["https://example.com/terms"])
    }
}
