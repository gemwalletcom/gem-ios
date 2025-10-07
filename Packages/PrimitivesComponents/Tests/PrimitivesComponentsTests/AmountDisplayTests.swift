// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
import PrimitivesTestKit
import Formatters

@testable import PrimitivesComponents

struct AmountDisplayTests {
    let asset = Asset.mock()
    let price = Price.mock(price: 1.5)
    let value = BigInt(100_000_000)
    let currency = "USD"

    @Test
    func numericFactory() {
        let display = AmountDisplay.numeric(
            asset: asset,
            price: price,
            value: value,
            direction: .incoming,
            currency: currency,
            formatter: .full
        )
        
        guard case .numeric(let viewModel) = display else {
            Issue.record("Expected numeric display type")
            return
        }
        
        #expect(viewModel.amount.text.contains(asset.symbol))
        #expect(viewModel.amount.text == "+1 BTC")
        #expect(viewModel.fiat?.text == "$1.50")
    }

    @Test
    func symbolFactory() {
        let display = AmountDisplay.symbol(asset: asset)
        
        guard case .symbol(let viewModel) = display else {
            Issue.record("Expected symbol display type")
            return
        }
        
        #expect(viewModel.amount.text == asset.symbol)
    }

    @Test
    func amountDisplayable() {
        let numericDisplay = AmountDisplay.numeric(
            asset: asset,
            price: price,
            value: value,
            currency: currency
        )
        let symbolDisplay = AmountDisplay.symbol(asset: asset)
        
        #expect(numericDisplay.amount.text.contains(asset.symbol))
        #expect(symbolDisplay.amount.text == asset.symbol)
        #expect(numericDisplay.fiat?.text == "$1.50")
        #expect(symbolDisplay.fiat == nil)
    }

    @Test
    func fiatVisibility() {
        let display = AmountDisplay.numeric(
            asset: asset,
            price: price,
            value: value,
            currency: currency
        )
        
        let withFiat = display.fiatVisibility(true)
        let withoutFiat = display.fiatVisibility(false)
        
        #expect(withFiat.fiat?.text == "$1.50")
        #expect(withoutFiat.fiat == nil)
    }

    @Test
    func fiatVisibilitySymbolUnchanged() {
        let display = AmountDisplay.symbol(asset: asset)
        let modified = display.fiatVisibility(false)

        guard case .symbol = modified else {
            Issue.record("Symbol display should remain unchanged")
            return
        }

        #expect(modified.amount.text == asset.symbol)
    }

    @Test
    func currencyPositive() {
        let textValue = AmountDisplay.currency(value: 100.50, currencyCode: "USD")
        #expect(textValue.text == "+$100.50")
    }

    @Test
    func currencyNegative() {
        let textValue = AmountDisplay.currency(value: -50.25, currencyCode: "USD")
        #expect(textValue.text == "-$50.25")
    }

    @Test
    func currencyZero() {
        let textValue = AmountDisplay.currency(value: 0, currencyCode: "USD")
        #expect(textValue.text == "$0.00")
    }
}