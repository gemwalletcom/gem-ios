// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Gem
import PrimitivesTestKit
import Primitives

final class FiatQuoteViewModelTests: XCTestCase {

    func testAmount() {
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock()).amount, "0.00 BTC")
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12)).amount, "15.12 BTC")
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10, cryptoAmount: 15)).amount, "15.00 BTC")
    }

    func testRateText() {
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 0, cryptoAmount: 0)).rateText, "NaN")
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12)).rateText, "$0.67")
        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 50, cryptoAmount: 0.0018)).rateText, "$27,777.78")

        XCTAssertEqual(FiatQuoteViewModel(asset: .mock(), quote: .mock(fiatAmount: 10.123, cryptoAmount: 15.12, fiatCurrency: Currency.gbp.rawValue)).rateText, "£0.67")
    }
}
