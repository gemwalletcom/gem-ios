// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import PrimitivesComponents

struct RequiredValidatorTests {
    private let fieldName = "Wallet 1"

    @Test
    func validatesNonEmptyString() throws {
        let validator = RequiredValidator(requireName: "Wallet 1")
        try validator.validate("Alice")
    }

    @Test
    func throwsOnEmptyString() {
        let validator = RequiredValidator(requireName: "Wallet 1")

        #expect(throws: RequiredFieldError.field(name: fieldName)) {
            try validator.validate("")
        }
    }

    @Test
    func throwsOnWhitespaceOnly() {
        let validator = RequiredValidator(requireName: "Wallet 1")

        #expect(throws: RequiredFieldError.field(name: fieldName)) {
            try validator.validate("   \n\t")
        }
    }
}
