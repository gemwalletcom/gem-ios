// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import FiatConnect
import PrimitivesTestKit
import Primitives

struct FiatQuoteViewModelTests {

    let formatter = CurrencyFormatter(type: .currency, currencyCode: "USD")
    
    @Test func testAmount() async throws {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(), formatter: formatter).amount == "0.00 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: formatter).amount == "15.12 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15), formatter: formatter).amount == "15.00 BTC")
    }
    
    func testRateText() {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 0, cryptoAmount: 0), formatter: formatter).rateText == "NaN")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: formatter).rateText == "$0.67")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: formatter).rateText == "$27,777.78")
        
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12, fiatCurrency: Currency.gbp.rawValue), formatter: formatter).rateText == "£0.67")
    }
}
