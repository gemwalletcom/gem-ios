// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Components
import struct Gemstone.GemEip712MessageDomain
import struct Gemstone.GemEip712Message
import struct Gemstone.SiweMessage
@testable import WalletConnector

struct MessagePreviewViewModelTests {
    
    @Test
    func textMessage() {
        let viewModel = MessagePreviewViewModel(message: .text("Hello World"))
        
        guard case .text(let text) = viewModel.messageDisplayType else {
            Issue.record()
            return
        }
        
        #expect(text == "Hello World")
    }
    
    @Test
    func eip712WithVerifyingContract() {
        let domain = GemEip712MessageDomain(
            name: "Test",
            version: "1",
            chainId: 1,
            verifyingContract: "0x123",
            salts: nil
        )
        let viewModel = MessagePreviewViewModel(message: .eip712(GemEip712Message(domain: domain, message: [])))
        
        guard case .sections(let sections) = viewModel.messageDisplayType else {
            Issue.record()
            return
        }
        
        #expect(sections[0].values.count == 2)
        #expect(sections[0].values[1].value == "0x123")
    }
    
    @Test
    func eip712WithoutVerifyingContract() {
        let domain = GemEip712MessageDomain(
            name: "Test",
            version: "1",
            chainId: 1,
            verifyingContract: nil,
            salts: nil
        )
        let viewModel = MessagePreviewViewModel(message: .eip712(GemEip712Message(domain: domain, message: [])))
        
        guard case .sections(let sections) = viewModel.messageDisplayType else {
            Issue.record()
            return
        }
        
        #expect(sections[0].values.count == 1)
    }

    @Test
    func siwePreview() {
        let message = SiweMessage(
            domain: "login.xyz",
            address: "0x123",
            uri: "https://login.xyz",
            chainId: 1,
            nonce: "abcdefgh",
            version: "1",
            issuedAt: "2024-04-01T12:00:00Z"
        )
        let viewModel = MessagePreviewViewModel(message: .siwe(message))

        guard case .siwe(let preview) = viewModel.messageDisplayType else {
            Issue.record()
            return
        }

        #expect(preview.domain == "login.xyz")
        #expect(preview.address == "0x123")
        #expect(preview.nonce == "abcdefgh")
    }
}
