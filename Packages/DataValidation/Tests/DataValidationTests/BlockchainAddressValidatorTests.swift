// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import DataValidation

struct BlockchainAddressValidatorTests {
    private var validAddress = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
    
    @Test
    func testIsValidWithValidAddress() throws {
        let validator = BlockchainAddressValidator(chain: .bitcoin, errorMessage: "")
        try validator.validate(validAddress)
    }
    
    @Test
    func testIsValidWithInvalidAddress() throws {
        let validator = BlockchainAddressValidator(chain: .bitcoin, errorMessage: "")
        #expect(throws: ValidationError.self) {
            try validator.validate("InvalidAddress123")
        }
    }
}
