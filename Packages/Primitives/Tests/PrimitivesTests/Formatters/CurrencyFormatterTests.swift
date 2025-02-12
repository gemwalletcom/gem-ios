// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Primitives

final class CurrencyFormatterTests {

    let currencyFormatterUS = CurrencyFormatter(locale: .US, currencyCode: "USD")
    let percentFormatterUS = CurrencyFormatter(type: .percent, locale: .US, currencyCode: "USD")

    let currencyFormatterUK = CurrencyFormatter(locale: .UK, currencyCode: "GBP")
    let percentFormatterUK = CurrencyFormatter(type: .percent, locale: .UK, currencyCode: "GBP")
    let percentSignLess = CurrencyFormatter(type: .percentSignLess, locale: .US, currencyCode: "USD")

    let cryptoFormatter = CurrencyFormatter(type: .currency, locale: .US, currencyCode: "")

    @Test
    func testCurrency() {
        #expect(currencyFormatterUS.string(0) == "$0.00")
        #expect(currencyFormatterUS.string(11.12) == "$11.12")
        #expect(currencyFormatterUS.string(11) == "$11.00")
        #expect(currencyFormatterUS.string(12000123) == "$12,000,123.00")
        #expect(currencyFormatterUS.string(0.0000000002) == "$0.0000000002")
        #expect(currencyFormatterUS.string(0.0000000000001) == "$0.00")
    }

    @Test
    func testSmallValue() {
        #expect(currencyFormatterUS.string(0.10) == "$0.10")
        #expect(currencyFormatterUS.string(0.11) == "$0.11")
        #expect(currencyFormatterUS.string(0.2) == "$0.20")
        #expect(currencyFormatterUS.string(0.99) == "$0.99")
        #expect(currencyFormatterUS.string(1.89999) == "$1.90")
        #expect(currencyFormatterUS.string(0.70) == "$0.70")
        #expect(currencyFormatterUS.string(0.0345) == "$0.034")
        #expect(currencyFormatterUS.string(0.01) == "$0.01")
        #expect(currencyFormatterUS.string(0.13) == "$0.13")
        #expect(currencyFormatterUS.string(0.0123) == "$0.012")
        #expect(currencyFormatterUS.string(0.002) == "$0.002")
        #expect(currencyFormatterUS.string(0.001) == "$0.001")
        #expect(currencyFormatterUS.string(0.000123456) == "$0.00012")
        #expect(currencyFormatterUS.string(0.00000123) == "$0.0000012")
    }

    @Test
    func testCurrencyIncludeSign() {
        var formatter = currencyFormatterUS
        formatter.includePlusSign = true

        #expect(formatter.string(0) == "$0.00")
        #expect(formatter.string(11.12) == "+$11.12")
        #expect(formatter.string(-1.2) == "-$1.20")
    }

    @Test
    func testCurrencyGBPLocale() {
        #expect(currencyFormatterUK.string(0.0002) == "£0.0002")
        #expect(currencyFormatterUK.string(11.12) == "£11.12")
        #expect(currencyFormatterUK.string(11) == "£11.00")
        #expect(currencyFormatterUK.string(12000123) == "£12,000,123.00")
    }

    @Test
    func testPercent() {
        #expect(percentFormatterUS.string(-1.23) == "-1.23%")
        #expect(percentFormatterUS.string(11.12) == "+11.12%")
        #expect(percentFormatterUS.string(11) == "+11.00%")
        #expect(percentFormatterUS.string(12000123) == "+12,000,123.00%")

        #expect(percentFormatterUK.string(-1.23) == "-1.23%")
        #expect(percentFormatterUK.string(11.12) == "+11.12%")
        #expect(percentFormatterUK.string(11) == "+11.00%")
        #expect(percentFormatterUK.string(12000123) == "+12,000,123.00%")
    }

    @Test
    func testPercentSignLess() {
        #expect(percentSignLess.string(-1.23) == "-1.23%")
        #expect(percentSignLess.string(11.12) == "11.12%")
        #expect(percentSignLess.string(11) == "11.00%")
        #expect(percentSignLess.string(12000123) == "12,000,123.00%")
    }

    @Test
    func testDecimal() {
        #expect(cryptoFormatter.string(decimal: Decimal(0.12)) == "0.12")
        #expect(cryptoFormatter.string(decimal: Decimal(0.00012)) == "0.00012")

        #expect(cryptoFormatter.string(decimal: Decimal(11.12)) == "11.12")
        #expect(cryptoFormatter.string(decimal: Decimal(11)) == "11.00")
        #expect(cryptoFormatter.string(decimal: Decimal(12000123)) == "12,000,123.00")
    }
}
