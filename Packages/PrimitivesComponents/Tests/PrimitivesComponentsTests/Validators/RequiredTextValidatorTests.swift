// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import PrimitivesComponents

struct RequiredTextValidatorTests {
    private let fieldName = "Wallet 1"

    @Test
    func testValidatesNonEmpty() throws {
        let validator = RequiredTextValidator(requireName: fieldName)
        try validator.validate("Alice")
    }

    @Test
    func testThrowsOnEmpty() {
        let validator = RequiredTextValidator(requireName: fieldName)
        #expect(throws: RequiredFieldError(field: fieldName)) {
            try validator.validate("")
        }
    }

    @Test
    func testThrowsOnWhitespaceOnly() {
        let validator = RequiredTextValidator(requireName: fieldName)
        #expect(throws: RequiredFieldError(field: fieldName)) {
            try validator.validate(" \n\t")
        }
    }
}
