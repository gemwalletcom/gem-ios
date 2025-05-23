// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives

@testable import PrimitivesComponents

struct MinimumValueValidatorTests {
    private let min = BigInt(10)
    private let minText = "10 SOL"

    @Test
    func testPassesEqualOrGreater() throws {
        let validator = MinimumValueValidator<BigInt>(
            minimumValue: min,
            minimumValueText: minText
        )
        try validator.validate(min)
        try validator.validate(min + 1)
    }

    @Test
    func testThrowsBelowMinimum() {
        let validator = MinimumValueValidator<BigInt>(
            minimumValue: min,
            minimumValueText: minText
        )
        #expect(throws: TransferError.minimumAmount(string: minText)) {
            try validator.validate(min - 1)
        }
    }
}
