// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives

@testable import PrimitivesComponents

struct BalanceValueValidatorTests {
    private let asset = Asset.mock()
    private let available = BigInt(50)

    @Test
    func testPassesWithinBalance() throws {
        let validator = BalanceValueValidator<BigInt>(
            available: available,
            asset: asset
        )
        try validator.validate(available)
        try validator.validate(available - 10)
    }

    @Test
    func testThrowsExceedingBalance() {
        let validator = BalanceValueValidator<BigInt>(
            available: available,
            asset: asset
        )
        #expect(throws: TransferAmountCalculatorError.insufficientBalance(asset)) {
            try validator.validate(available + 1)
        }
    }
}
