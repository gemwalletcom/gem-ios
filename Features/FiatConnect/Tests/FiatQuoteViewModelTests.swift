// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import FiatConnect
import PrimitivesTestKit
import Primitives
import Formatters

struct FiatQuoteViewModelTests {
    let usFormatter = CurrencyFormatter(locale: .US, currencyCode: Currency.usd.rawValue)
    let ukFormatter = CurrencyFormatter(locale: .UK, currencyCode: Currency.usd.rawValue)
    let uaFormatter = CurrencyFormatter(locale: .UA, currencyCode: Currency.usd.rawValue)
    let frFormatter = CurrencyFormatter(locale: .FR, currencyCode: Currency.usd.rawValue)

    @Test
    func testBuyAmount() async throws {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(), formatter: usFormatter).amountText == "0.00 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: usFormatter).amountText == "15.12 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15), formatter: usFormatter).amountText == "15.00 BTC")
    }

    @Test
    func testSellAmount() async throws {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(type: .sell), formatter: usFormatter).amountText == "0.00 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12, type: .sell), formatter: usFormatter).amountText == "15.12 BTC")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15, type: .sell), formatter: usFormatter).amountText == "15.00 BTC")
    }

    @Test
    func testRateText() {
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 0, cryptoAmount: 0), formatter: usFormatter).rateText == "NaN")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: usFormatter).rateText == "$0.6695")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: usFormatter).rateText == "$27,777.78")

        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: ukFormatter).rateText == "US$0.6695")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: ukFormatter).rateText == "US$27,777.78")

        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: uaFormatter).rateText == "0,6695 $")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: uaFormatter).rateText == "27 777,78 $")

        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12), formatter: frFormatter).rateText == "0,6695 $ US")
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018), formatter: frFormatter).rateText == "27 777,78 $ US")
        
        #expect(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 0.000000123456, cryptoAmount: 1), formatter: frFormatter).rateText == "0,0000001235 $ US")
    }
}
