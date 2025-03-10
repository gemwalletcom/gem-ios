// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import DataValidation

struct StringLengthValidatorTests {
    
    @Test
    func testValidInput() throws {
        let validator = StringLengthValidator(min: 0, max: 10, errorMessage: "")
        try validator.validate(String(repeating: "A", count: 8))
        try validator.validate("")
    }
    
    @Test
    func testInvalidInput() {
        let validator = StringLengthValidator(min: 1, max: 10, errorMessage: "")
        
        #expect(throws: ValidationError.self, performing: {
            try validator.validate("")
            try validator.validate(String(repeating: "A", count: 11))
        })
    }
}
