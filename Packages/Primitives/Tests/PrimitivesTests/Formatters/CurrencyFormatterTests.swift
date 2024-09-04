// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Primitives

final class CurrencyFormatterTests: XCTestCase {
    
    let currencyFormatterUS = CurrencyFormatter(locale: .US, currencyCode: "USD")
    let percentFormatterUS = CurrencyFormatter(type: .percent, locale: .US, currencyCode: "USD")
    
    let currencyFormatterUK = CurrencyFormatter(locale: .UK, currencyCode: "GBP")
    let percentFormatterUK = CurrencyFormatter(type: .percent, locale: .UK, currencyCode: "GBP")
    let percentSignLess = CurrencyFormatter(type: .percentSignLess, locale: .US, currencyCode: "USD")
    
    let cryptoFormatter = CurrencyFormatter(type: .currency, locale: .US, currencyCode: "")
    
    func testCurrency() {
        XCTAssertEqual(currencyFormatterUS.string(0), "$0.00")
        XCTAssertEqual(currencyFormatterUS.string(11.12), "$11.12")
        XCTAssertEqual(currencyFormatterUS.string(11), "$11.00")
        XCTAssertEqual(currencyFormatterUS.string(12000123), "$12,000,123.00")
    }
    
    func testSmallValue() {
        XCTAssertEqual(currencyFormatterUS.string(0.1), "$0.10")
        XCTAssertEqual(currencyFormatterUS.string(0.7), "$0.70")
        XCTAssertEqual(currencyFormatterUS.string(0.01), "$0.01")
        XCTAssertEqual(currencyFormatterUS.string(0.002), "$0.002")
        XCTAssertEqual(currencyFormatterUS.string(0.001), "$0.001")
        XCTAssertEqual(currencyFormatterUS.string(0.000123456), "$0.00012")
        XCTAssertEqual(currencyFormatterUS.string(0.00000123), "$0.0000012")
    }
    
    func testCurrencyIncludeSign() {
        var formatter = currencyFormatterUS
        formatter.includePlusSign = true
        
        XCTAssertEqual(formatter.string(0), "$0.00")
        XCTAssertEqual(formatter.string(11.12), "+$11.12")
        XCTAssertEqual(formatter.string(-1.2), "-$1.20")
    }
    
    func testCurrencyGBPLocale() {
        XCTAssertEqual(currencyFormatterUK.string(0.0002), "£0.0002")
        XCTAssertEqual(currencyFormatterUK.string(11.12), "£11.12")
        XCTAssertEqual(currencyFormatterUK.string(11), "£11.00")
        XCTAssertEqual(currencyFormatterUK.string(12000123), "£12,000,123.00")
    }
    
    func testPercent() {
        XCTAssertEqual(percentFormatterUS.string(-1.23), "-1.23%")
        XCTAssertEqual(percentFormatterUS.string(11.12), "+11.12%")
        XCTAssertEqual(percentFormatterUS.string(11), "+11.00%")
        XCTAssertEqual(percentFormatterUS.string(12000123), "+12,000,123.00%")
        
        XCTAssertEqual(percentFormatterUK.string(-1.23), "-1.23%")
        XCTAssertEqual(percentFormatterUK.string(11.12), "+11.12%")
        XCTAssertEqual(percentFormatterUK.string(11), "+11.00%")
        XCTAssertEqual(percentFormatterUK.string(12000123), "+12,000,123.00%")
    }
    
    func testPercentSignLess() {
        XCTAssertEqual(percentSignLess.string(-1.23), "-1.23%")
        XCTAssertEqual(percentSignLess.string(11.12), "11.12%")
        XCTAssertEqual(percentSignLess.string(11), "11.00%")
        XCTAssertEqual(percentSignLess.string(12000123), "12,000,123.00%")
    }
    
    func testDecimal() {
        XCTAssertEqual(cryptoFormatter.string(decimal: Decimal(0.12)), "0.12")
        XCTAssertEqual(cryptoFormatter.string(decimal: Decimal(0.00012)), "0.00012")
        
        XCTAssertEqual(cryptoFormatter.string(decimal: Decimal(11.12)), "11.12")
        XCTAssertEqual(cryptoFormatter.string(decimal: Decimal(11)), "11.00")
        XCTAssertEqual(cryptoFormatter.string(decimal: Decimal(12000123)), "12,000,123.00")
    }
}
