// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Primitives
import Style
import PrimitivesComponentsTestKit
@testable import PrimitivesComponents

struct ChartPriceViewModelTests {

    @Test
    func chartPriceViewModel() {
        #expect(ChartPriceViewModel.mock(price: 100).priceText == "$100.00")
        #expect(ChartPriceViewModel.mock(price: 100, signed: true).priceText == "+$100.00")
        #expect(ChartPriceViewModel.mock(price: -50, signed: true).priceText == "-$50.00")

        #expect(ChartPriceViewModel.mock(price: 100).priceColor == Colors.black)
        #expect(ChartPriceViewModel.mock(price: 100, signed: true).priceColor == Colors.green)

        #expect(ChartPriceViewModel.mock(price: 100, priceChangePercentage: 5.5).priceChangeText == "+5.50%")
        #expect(ChartPriceViewModel.mock(price: 100, signed: true).priceChangeText == nil)
        #expect(ChartPriceViewModel.mock(price: 0).priceChangeText == nil)

        #expect(ChartPriceViewModel.mock(priceChangePercentage: 10).priceChangeTextColor == Colors.green)
        #expect(ChartPriceViewModel.mock(priceChangePercentage: -10).priceChangeTextColor == Colors.red)

        #expect(ChartPriceViewModel.mock(date: nil).dateText == nil)
        #expect(ChartPriceViewModel.mock(date: Date()).dateText != nil)
    }
}
