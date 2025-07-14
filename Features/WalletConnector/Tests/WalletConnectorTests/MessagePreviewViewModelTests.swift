// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Components
import Gemstone
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
}