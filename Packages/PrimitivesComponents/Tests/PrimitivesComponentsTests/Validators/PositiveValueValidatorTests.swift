// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt

@testable import PrimitivesComponents

struct PositiveValueValidatorTests {
    @Test
    func testValidatesPositiveValue() throws {
        let validator = PositiveValueValidator<BigInt>()
        try validator.validate(1)
        try validator.validate(123_456)
    }

    @Test
    func testThrowsOnZero() {
        let validator = PositiveValueValidator<BigInt>()
        #expect(throws: TransferError.invalidAmount) {
            try validator.validate(0)
        }
    }

    @Test
    func testThrowsOnNegative() {
        let validator = PositiveValueValidator<BigInt>()
        #expect(throws: TransferError.invalidAmount) {
            try validator.validate(-42)
        }
    }

    @Test
    func testSilentValidatorThrowsNonPositiveError() {
        let validator = PositiveValueValidator<BigInt>(isSilent: true)

        #expect(throws: SilentValidationError.self) {
            try validator.validate(0)
        }

        #expect(throws: SilentValidationError.self) {
            try validator.validate(-7)
        }
    }

    @Test
    func testSilentValidatorPassesPositiveValue() throws {
        let validator = PositiveValueValidator<BigInt>(isSilent: true)
        try validator.validate(88)
    }
}
