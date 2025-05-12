// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import WalletConnector

@Test
func textMessageViewModelTests() async throws {
    let message: String = try Bundle.decode(from: "eip712", withExtension: "json", in: .module)
    let viewModel = TextMessageViewModel(message: message)
    
    let expectedMessage: String = try Bundle.decode(from: "eip712pretty", withExtension: "json", in: .module)
    #expect(viewModel.text == expectedMessage)
}
