// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Style
import PrimitivesComponentsTestKit
@testable import PrimitivesComponents

struct PriceChangeViewModelTests {

    @Test
    func textPositive() {
        #expect(PriceChangeViewModel.mock(value: 100).text == "+$100.00")
        #expect(PriceChangeViewModel.mock(value: 0).text == "+$0.00")
    }

    @Test
    func textNegative() {
        #expect(PriceChangeViewModel.mock(value: -50).text == "-$50.00")
    }

    @Test
    func textNil() {
        #expect(PriceChangeViewModel.mock(value: nil).text == nil)
    }

    @Test
    func color() {
        #expect(PriceChangeViewModel.mock(value: 100).color == Colors.green)
        #expect(PriceChangeViewModel.mock(value: -50).color == Colors.red)
        #expect(PriceChangeViewModel.mock(value: 0).color == Colors.gray)
        #expect(PriceChangeViewModel.mock(value: nil).color == .secondary)
    }
}
