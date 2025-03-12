// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import DataValidation

struct ChainSelectionValidatorTests {
    @Test
    func testIsValidWithSelectedChain() throws {
        let validator = ChainSelectionValidator(errorMessage: "")
        try validator.validate(.bitcoin)
    }
    
    @Test
    func testIsValidWithNoSelectedChain() {
        let validator = ChainSelectionValidator(errorMessage: "")
        #expect(throws: ValidationError.self, performing: {
            try validator.validate(nil)
        })
    }
}
