// Copyright (c). Gem Wallet. All rights reserved.

import Testing

@testable import Validators

struct URLTextValidatorTests {
    @Test
    func validate() {
        #expect(throws: Never.self) { try URLTextValidator().validate("https://eth.llamarpc.com") }
        #expect(throws: Never.self) { try URLTextValidator().validate("https://eth-mainnet.rpcfast.com?api_key=test") }
        #expect(throws: Never.self) { try URLTextValidator().validate("eth.llamarpc.com") }

        #expect(throws: URLValidationError.self) { try URLTextValidator().validate("http://example.com") }
        #expect(throws: URLValidationError.self) { try URLTextValidator().validate("ws://example.com") }
        #expect(throws: URLValidationError.self) { try URLTextValidator().validate("hello") }
        #expect(throws: URLValidationError.self) { try URLTextValidator().validate("") }
    }
}
