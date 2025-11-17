// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Testing
@testable import PrimitivesComponents

struct PriceViewModelTests {
    let currencyCode = Currency.usd.id

    @Test
    func testIsPriceAvailable() {
        #expect(PriceViewModel(price: nil, currencyCode: currencyCode).isPriceAvailable == false)
        #expect(PriceViewModel(price: .mock(price: 0, priceChangePercentage24h: 0), currencyCode: currencyCode).isPriceAvailable == false)
        #expect(PriceViewModel(price: .mock(price: 10), currencyCode: currencyCode).isPriceAvailable)
    }

    @Test
    func testPriceAmountText() {
        #expect(PriceViewModel(price: .mock(price: 1.2), currencyCode: currencyCode).priceAmountText == "$1.20")
        #expect(PriceViewModel(price: .mock(price: 10), currencyCode: currencyCode).priceAmountText == "$10.00")
        #expect(PriceViewModel(price: .mock(price: 0.000000123), currencyCode: currencyCode).priceAmountText == "$0.000000123")
        #expect(PriceViewModel(price: .mock(price: 0.00000000123), currencyCode: currencyCode).priceAmountText == "$0.00000000123")
        #expect(PriceViewModel(price: .mock(price: 0.000000123456), currencyCode: currencyCode).priceAmountText == "$0.0000001235")
        #expect(PriceViewModel(price: .mock(price: -10), currencyCode: currencyCode).priceAmountText == "-$10.00")
        
        #expect(PriceViewModel(price: .mock(price: 123_456), currencyCode: currencyCode).priceAmountText == "$123.46K")
        #expect(PriceViewModel(price: .mock(price: 10_123_456), currencyCode: currencyCode).priceAmountText == "$10.12M")
    }

    @Test
    func testPriceAmountChangeText() {
        #expect(PriceViewModel(price: .mock(priceChangePercentage24h: 5), currencyCode: currencyCode).priceChangeText == "+5.00%")
        #expect(PriceViewModel(price: .mock(priceChangePercentage24h: -5), currencyCode: currencyCode).priceChangeText == "-5.00%")
    }
}
