// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Testing

@testable import Currency

private final class MockCurrencyStorage: CurrencyStorable, @unchecked Sendable {
    var currency: String
    init(currency: String = "USD") {
        self.currency = currency
    }
}

struct CurrencySceneViewModelTests {
    private var storage = MockCurrencyStorage()

    @Test
    func testUSDCurrencyValue() {
        let usdCurrencyStorage = MockCurrencyStorage()
        let viewModel = CurrencySceneViewModel(currencyStorage: usdCurrencyStorage)
        #expect(viewModel.selectedCurrencyValue == "🇺🇸 USD")
    }

    @Test
    func testGBPCurrencyValue() {
        let gbpCurrancyStorage = MockCurrencyStorage(currency: "GBP")
        let viewModel = CurrencySceneViewModel(currencyStorage: gbpCurrancyStorage)
        #expect(viewModel.selectedCurrencyValue == "🇬🇧 GBP")
    }

    @Test
    func testSetNewCurrency() {
        let usdCurrencyStorage = MockCurrencyStorage()
        let viewModel = CurrencySceneViewModel(currencyStorage: usdCurrencyStorage)
        viewModel.setCurrency(.ars)
        
        #expect(usdCurrencyStorage.currency == Currency.ars.id)
        #expect(usdCurrencyStorage.currency == viewModel.currency.id)

    }
}
