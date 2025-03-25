// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation
import Testing
@testable import PrimitivesComponents

struct PriceViewModelTests {
    let currencyCode = Currency.usd.id

    @Test
    func testIsPriceAvailable() {
        #expect(!PriceViewModel(price: nil, currencyCode: currencyCode).isPriceAvailable)
        #expect(!PriceViewModel(price: Price(price: 0, priceChangePercentage24h: 0), currencyCode: currencyCode).isPriceAvailable)
        #expect(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5), currencyCode: currencyCode).isPriceAvailable)
    }

    @Test
    func testPriceAmountText() {
        #expect(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5), currencyCode: currencyCode).priceAmountText == "$10.00")
        #expect(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5), currencyCode: currencyCode).priceAmountText == "-$10.00")
        
        #expect(PriceViewModel(price: Price(price: 123_456, priceChangePercentage24h: 5), currencyCode: currencyCode).priceAmountText == "$123.46K")
        #expect(PriceViewModel(price: Price(price: 10_123_456, priceChangePercentage24h: 5), currencyCode: currencyCode).priceAmountText == "$10.12M")
    }

    @Test
    func testPriceAmountPositiveText() {
        #expect(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5), currencyCode: currencyCode).priceAmountText == "$10.00")
        #expect(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5), currencyCode: currencyCode).priceAmountText == "-$10.00")
    }

    @Test
    func testPriceAmountChangeText() {
        #expect(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5), currencyCode: currencyCode).priceChangeText == "+5.00%")
        #expect(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5), currencyCode: currencyCode).priceChangeText == "-5.00%")
    }
}
