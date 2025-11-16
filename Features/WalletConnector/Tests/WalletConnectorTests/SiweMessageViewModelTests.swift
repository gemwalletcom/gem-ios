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
            expirationTime: "2024-04-02T12:00:00Z",
            notBefore: "2024-04-01T11:00:00Z",
            requestId: "req-123",
            resources: ["https://example.com/terms", " "]
        )

        let viewModel = SiweMessageViewModel(message: message)
        #expect(viewModel.domainText == "login.xyz")
        #expect(viewModel.addressText == "0x6dD7802E6d44bE89a789C4bD60bD511B68F41c7c")
        #expect(viewModel.statementText == "Sign in")
        #expect(viewModel.resources == ["https://example.com/terms"])
    }

    @Test
    func buildsDetailItemsWithAllFields() {
        let message = SiweMessage(
            domain: "login.xyz",
            scheme: "https",
            address: "0x6dD7802E6d44bE89a789C4bD60bD511B68F41c7c",
            statement: "Sign in",
            uri: "https://login.xyz",
            version: "1",
            chainId: 1,
            nonce: "nonceabcd",
            issuedAt: "2024-04-01T12:00:00Z",
            expirationTime: "2024-04-02T12:00:00Z",
            notBefore: "2024-04-01T11:00:00Z",
            requestId: "req-123",
            resources: []
        )

        let viewModel = SiweMessageViewModel(message: message)
        let dictionary = Dictionary(uniqueKeysWithValues: viewModel.detailItems.map { ($0.title, $0.value) })

        #expect(dictionary["Scheme"] == "https")
        #expect(dictionary["Chain ID"] == "1")
        #expect(dictionary["Nonce"] == "nonceabcd")
        #expect(dictionary["Issued At"] == "2024-04-01T12:00:00Z")
        #expect(dictionary["Expiration Time"] == "2024-04-02T12:00:00Z")
        #expect(dictionary["Not Before"] == "2024-04-01T11:00:00Z")
        #expect(dictionary["Request ID"] == "req-123")
        #expect(dictionary["Statement"] == "Sign in")
    }
}
