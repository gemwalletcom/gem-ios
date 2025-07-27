// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
@testable import Settings

struct CurrencyViewModelTests {
    @Test
    func testUSTitle() {
        let currency = Currency(rawValue: "USD")!
        let viewModel = CurrencyViewModel(currency: currency)
        #expect(viewModel.title == "🇺🇸 USD - US Dollar")
    }

    @Test
    func testEUROTitle() {
        let currency = Currency(rawValue: "EUR")!
        let viewModel = CurrencyViewModel(currency: currency)
        #expect(viewModel.title == "🇪🇺 EUR - Euro")
    }
}
