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
    )
    -> FiatSceneViewModel {
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
        #expect(vm.amountText == String(format: "%.0f", FiatTransactionTypeViewModel(type: .buy).defaultAmount))

        vm.selectType(.sell)
        #expect(vm.amountText == "")
    }

    @Test
    func testStatesChanges() {
        let vm = FiatSceneViewModelTests.mock()
        vm.changeAmountText("", text: "100")
        #expect(vm.input.type == .buy)
        #expect(vm.input.amount == 100)

        vm.selectType(.sell)
        #expect(vm.input.type == .sell)
        #expect(vm.input.amount != 100)
        vm.changeAmountText("", text: "200")

        vm.selectType(.buy)
        #expect(vm.input.amount == 100)
    }

    @Test
    func testSelectBuyAmount() {
        let vm = FiatSceneViewModelTests.mock()
        vm.select(amount: 150, assetData: .empty)
        #expect(vm.amountText == "150")

        vm.select(amount: 1.1, assetData: .empty)
        #expect(vm.amountText != "1.1")
        #expect(vm.amountText == "1")
    }

    @Test
    func testSelectSellAmount() {
        let vm = FiatSceneViewModelTests.mock()
        vm.selectType(.sell)
        vm.select(
            amount: 50,
            assetData: .mock(balance: Balance(available: 100_000.asBigInt))
        )
        #expect(vm.amountText == "0.0005")

        vm.select(
            amount: 100,
            assetData: .mock(balance: Balance(available: 100_000.asBigInt))
        )
        #expect(vm.amountText == "0.001")
    }

    @Test
    func testCurrencySymbol() {
        let vm = FiatSceneViewModelTests.mock()
        #expect(vm.currencyInputConfig.currencySymbol == "$")

        vm.selectType(.sell)
        #expect(vm.currencyInputConfig.currencySymbol == vm.asset.symbol)
    }

    @Test
    func testButtonsTitle() {
        let vm = FiatSceneViewModelTests.mock()
        #expect(vm.buttonTitle(amount: 10.0) == "$10")

        vm.selectType(.sell)
        #expect(vm.buttonTitle(amount: 1.3) == "1%")
    }

    @Test
    func testRateValue() {
        let vm = FiatSceneViewModelTests.mock()
        let quote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 2.0, type: vm.input.type)

        #expect(vm.rateValue(for: quote) ==  "1 BTC ≈ $600.00")
    }

    @Test
    func testCryptoAmountValue() {
        let vm = FiatSceneViewModelTests.mock()
        let buyQuote = FiatQuote.mock(fiatAmount: 0, cryptoAmount: 1, type: vm.input.type)
        vm.input.quote = buyQuote
        #expect(vm.cryptoAmountValue == "≈ 1.00 BTC")

        vm.selectType(.sell)
        let sellQuote = FiatQuote.mock(fiatAmount: 2400, cryptoAmount: 1, type: vm.input.type)
        vm.input.quote = sellQuote

        #expect(vm.cryptoAmountValue == "≈ 2,400.00 $")
    }
}
