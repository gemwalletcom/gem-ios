// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import PrimitivesComponents

struct LeverageOptionTests {

    @Test
    func testLeverageOption() {
        let allOptions = LeverageOption.allOptions
        let maxLeverage4 = allOptions.filter { $0.value <= 4 }

        #expect(LeverageOption.option(desiredValue: 10, from: allOptions).value == 10)
        #expect(LeverageOption.option(desiredValue: 5, from: allOptions).value == 5)
        #expect(LeverageOption.option(desiredValue: 4, from: allOptions).value == 5)
        #expect(LeverageOption.option(desiredValue: 8, from: allOptions).value == 10)
        #expect(LeverageOption.option(desiredValue: 10, from: maxLeverage4).value == 3)
        #expect(LeverageOption.option(desiredValue: 50, from: maxLeverage4).value == 3)
        #expect(LeverageOption.option(desiredValue: 10, from: []).value == 1)
    }
}
