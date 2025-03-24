// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import GemAPI
import Primitives

@testable import FiatConnect

@MainActor
final class FiatSceneViewModelTests {
    private static func mock(
        service: any GemAPIFiatService = GemAPIService(),
        currencyFormatter: CurrencyFormatter = .init(locale: Locale.US, currencyCode: Currency.usd.rawValue),
        assetAddress: AssetAddress = .mock(),
        walletId: String = UUID().uuidString
    ) -> FiatSceneViewModel {
        FiatSceneViewModel(
            fiatService: service,
            currencyFormatter: currencyFormatter,
            assetAddress: assetAddress,
            walletId: walletId
        )
    }

    @Test
    func testDefaultAmountText() {
        let vm = FiatSceneViewModelTests.mock()
        #expect(vm.amountText == String(format: "%.0f", FiatQuoteTypeViewModel(type: .buy).defaultAmount))

        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)

        #expect(vm.amountText == "")
    }

    @Test
    func testStatesChanges() {
        let vm = FiatSceneViewModelTests.mock()
        vm.onChangeAmountText("", text: "100")

        #expect(vm.input.type == .buy)
        #expect(vm.input.amount == 100)

        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)

        #expect(vm.input.type == .sell)
        #expect(vm.input.amount != 100)

        vm.onChangeAmountText("", text: "200")

        vm.input.type = .buy
        vm.onChangeType(.sell, type: .buy)

        #expect(vm.input.amount == 100)
    }

    @Test
    func testSelectBuyAmount() {
        let vm = FiatSceneViewModelTests.mock()
        vm.onSelect(amount: 150)

        #expect(vm.amountText == "150")

        vm.onSelect(amount: 1.1)

        #expect(vm.amountText != "1.1")
        #expect(vm.amountText == "1")
    }

    @Test
    func testSelectSellAmount() {
        let vm = FiatSceneViewModelTests.mock()
        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)
        vm.assetData = .mock(balance: Balance(available: 100_000.asBigInt))

        vm.onSelect(amount: 50)

        #expect(vm.amountText == "0.0005")

        vm.onSelect(amount: 100)

        #expect(vm.amountText == "0.001")
    }

    @Test
    func testCurrencySymbol() {
        let vm = FiatSceneViewModelTests.mock()
        #expect(vm.currencyInputConfig.currencySymbol == "$")

        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)

        #expect(vm.currencyInputConfig.currencySymbol == vm.asset.symbol)
    }

    @Test
    func testButtonsTitle() {
        let vm = FiatSceneViewModelTests.mock()

        #expect(vm.buttonTitle(amount: 10.0) == "$10")

        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)

        #expect(vm.buttonTitle(amount: 1.3) == "1%")
    }

    @Test
    func testRateValue() {
        let vm = FiatSceneViewModelTests.mock()
        let quote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 2.0, type: vm.input.type)

        #expect(vm.rateValue(for: quote) == "1 \(vm.asset.symbol) ≈ $600.00")
    }

    @Test
    func testCryptoAmountValue() {
        let vm = FiatSceneViewModelTests.mock()
        let buyQuote = FiatQuote.mock(fiatAmount: 0, cryptoAmount: 1, type: vm.input.type)
        vm.input.quote = buyQuote
        #expect(vm.cryptoAmountValue == "≈ 1.00 \(vm.asset.symbol)")

        vm.input.type = .sell
        vm.onChangeType(.buy, type: .sell)
        let sellQuote = FiatQuote.mock(fiatAmount: 2400, cryptoAmount: 1, type: vm.input.type)
        vm.input.quote = sellQuote

        #expect(vm.cryptoAmountValue == "≈ 2,400.00 \(vm.currencyFormatter.symbol)")
    }
}
