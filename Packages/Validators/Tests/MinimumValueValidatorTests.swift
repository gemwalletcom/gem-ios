// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives

@testable import Validators

struct MinimumValueValidatorTests {
    private let min = BigInt(10)
    private let asset = Asset.mockBNB()

    @Test
    func testPassesEqualOrGreater() throws {
        let validator = MinimumValueValidator<BigInt>(
            minimumValue: min,
            asset: asset
        )
        try validator.validate(min)
        try validator.validate(min + 1)
    }

    @Test
    func testThrowsBelowMinimum() {
        let validator = MinimumValueValidator<BigInt>(
            minimumValue: min,
            asset: asset
        )
        #expect(throws: TransferError.minimumAmount(asset: asset, required: min)) {
            try validator.validate(min - 1)
        }
    }
}
