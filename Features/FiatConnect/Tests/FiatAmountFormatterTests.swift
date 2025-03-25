// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import FiatConnect
import PrimitivesTestKit
import Primitives

@testable import FiatConnect

struct FiatAmountFormatterTests {
    let valueFormatter = ValueFormatter(locale: .US, style: .medium)
    let btc = Asset.mock()
    var formatter: FiatAmountFormatter {
        FiatAmountFormatter(valueFormatter: valueFormatter, decimals: btc.decimals.asInt)
    }
    @Test
    func testFormatBuyAmount() {
        #expect(formatter.format(amount: 0, for: .buy) == "0")
        #expect(formatter.format(amount: 123.99, for: .buy) == "123")
        #expect(formatter.format(amount: 1.2345, for: .buy) == "1")
    }

    @Test
    func testFormatSellAmount() {
        #expect(formatter.format(amount: 10.0, for: .sell) == "10.00")
        #expect(formatter.format(amount: 0, for: .sell) == "")
        #expect(formatter.format(amount: 10.12345678, for: .sell) == "10.123456")
        #expect(formatter.format(amount: 5.5, for: .sell) == "5.50")
        #expect(formatter.format(amount: 0.12345678, for: .sell) == "0.123456")
    }

    @Test
    func testParseBuyAmount() {
        #expect(formatter.parseAmount(from: "150", for: .buy) == 150)
        #expect(formatter.parseAmount(from: "150.75", for: .buy) == 150.75)
        #expect(formatter.parseAmount(from: "0", for: .buy) == 0)
        #expect(formatter.parseAmount(from: "999.999", for: .buy) == 999.999)
    }

    @Test
    func testParseSellAmount() {
        #expect(formatter.parseAmount(from: "10.00000000", for: .sell) == 10.0)
        #expect(formatter.parseAmount(from: "10.12345678", for: .sell) == 10.12345678)
        #expect(formatter.parseAmount(from: "5.50000000", for: .sell) == 5.5)
        #expect(formatter.parseAmount(from: "100.00000000", for: .sell) == 100.0)
    }

    @Test
    func testFormatCryptoValue() {
        #expect(formatter.formatCryptoValue(fiatAmount: 10.0, type: .sell) == "1000000000")
        #expect(formatter.formatCryptoValue(fiatAmount: 1.0, type: .sell) == "100000000")
        #expect(formatter.formatCryptoValue(fiatAmount: 0.5, type: .sell) == "50000000")
        #expect(formatter.formatCryptoValue(fiatAmount: 1234.56, type: .sell) == "123456000000")
        #expect(formatter.formatCryptoValue(fiatAmount: 10.0, type: .buy) == nil)
    }
}
