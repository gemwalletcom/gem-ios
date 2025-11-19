// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import struct Gemstone.SiweMessage
@testable import WalletConnector

struct SiweMessageViewModelTests {

    @Test
    func displaysAllRequiredFields() {
        let message = SiweMessage(
            domain: "login.xyz",
            address: "0x123",
            uri: "https://login.xyz",
            chainId: 1,
            nonce: "abcdefgh",
            version: "1",
            issuedAt: "2024-04-01T12:00:00Z"
        )

        let viewModel = SiweMessageViewModel(message: message)
        #expect(viewModel.detailItems.map(\.title) == ["Domain", "Address", "URI", "Chain ID", "Nonce", "Issued At", "Version"])
        #expect(viewModel.detailItems.map(\.value) == ["login.xyz", "0x123", "https://login.xyz", "1", "abcdefgh", "2024-04-01T12:00:00Z", "1"])
    }

    @Test
    func reflectsProvidedValues() {
        let message = SiweMessage(
            domain: "example.com",
            address: "0x987",
            uri: "https://example.com",
            chainId: 10,
            nonce: "ijklmnop",
            version: "1",
            issuedAt: "2024-05-01T10:00:00Z"
        )

        let viewModel = SiweMessageViewModel(message: message)
        let values = Dictionary(uniqueKeysWithValues: viewModel.detailItems)
        #expect(values["Domain"] == "example.com")
        #expect(values["Address"] == "0x987")
        #expect(values["URI"] == "https://example.com")
        #expect(values["Chain ID"] == "10")
        #expect(values["Nonce"] == "ijklmnop")
        #expect(values["Issued At"] == "2024-05-01T10:00:00Z")
        #expect(values["Version"] == "1")
    }
}
