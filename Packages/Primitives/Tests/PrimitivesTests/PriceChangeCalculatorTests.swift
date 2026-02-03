// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives

struct PriceChangeCalculatorTests {

    @Test
    func percentage() {
        #expect(PriceChangeCalculator.calculate(.percentage(from: 100, to: 110)) == 10)
        #expect(PriceChangeCalculator.calculate(.percentage(from: 100, to: 90)) == -10)
        #expect(PriceChangeCalculator.calculate(.percentage(from: 100, to: 100)) == 0)
        #expect(PriceChangeCalculator.calculate(.percentage(from: 0, to: 100)) == 0)
    }

    @Test
    func amount() {
        #expect(PriceChangeCalculator.calculate(.amount(percentage: 10, value: 110)) == 10)
        #expect(PriceChangeCalculator.calculate(.amount(percentage: -10, value: 90)) == -10)
        #expect(PriceChangeCalculator.calculate(.amount(percentage: 0, value: 100)) == 0)
    }
}
