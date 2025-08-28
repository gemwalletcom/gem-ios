// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import Localization

@testable import Validators

struct FiatRangeValidatorTests {
    private let range = 10...10000
    private let minimumText = "$10"
    private let maximumText = "$10,000"

    var validator: FiatRangeValidator {
        FiatRangeValidator(
            range: range,
            minimumValueText: minimumText,
            maximumValueText: maximumText
        )
    }

    @Test
    func testPassesWithinRange() throws {
        try validator.validate(10)
        try validator.validate(10000)
    }

    @Test
    func testThrowsBelowMinimum() {
        #expect(throws: AnyError(Localized.Transfer.minimumAmount(minimumText))) {
            try validator.validate(9)
        }
    }

    @Test
    func testThrowsAboveMaximum() {
        #expect(throws: AnyError(Localized.Transfer.maximumAmount(maximumText))) {
            try validator.validate(10001)
        }
    }
}
