// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives

@testable import Validators

struct MaximumValueValidatorTests {
    private let max = BigInt(100)
    private let maxText = "100 USDC"

    @Test
    func testPassesEqualOrLess() throws {
        let validator = MaximumValueValidator<BigInt>(
            maximumValue: max,
            maximumValueText: maxText
        )
        try validator.validate(max - 1)
        try validator.validate(max)
    }

    @Test
    func testThrowsAboveMaximum() {
        let validator = MaximumValueValidator<BigInt>(
            maximumValue: max,
            maximumValueText: maxText
        )
        #expect(throws: AnyError("Maximum allowed value is \(maxText)")) {
            try validator.validate(max + 1)
        }
    }
}
