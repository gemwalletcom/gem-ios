// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import FiatConnect
import PrimitivesTestKit
import Primitives

struct FiatQuoteViewModelTests {

    let formatter = CurrencyFormatter(type: .currency, currencyCode: "USD")
    
    @Test
    func testBuyAmount() async throws {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(), formatter: formatter).amountText == "0,00 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: formatter).amountText == "15,12 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15), formatter: formatter).amountText == "15,00 BTC")
    }

    @Test
    func testSellAmount() async throws {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(type: .sell), formatter: formatter).amountText == "0,00 $")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12, type: .sell), formatter: formatter).amountText == "10,12 $")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15, type: .sell), formatter: formatter).amountText == "10,00 $")
    }

    @Test
    func testRateText() {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 0, cryptoAmount: 0), formatter: formatter).rateText == "NaN")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: formatter).rateText == "0,67 US$")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: formatter).rateText == "27 777,78 US$")

        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12, fiatCurrency: Currency.gbp.rawValue), formatter: formatter).rateText == "0,67 £")
    }
}
