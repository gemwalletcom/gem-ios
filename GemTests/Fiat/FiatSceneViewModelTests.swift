// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import GemAPI
import FiatConnect
import PrimitivesTestKit
import Primitives

@testable import Gem

struct FiatSceneViewModelTests {
    private static func mock(
        service: any GemAPIFiatService = GemAPIService(),
        assetAddress: AssetAddress = .mock(),
        walletId: String = UUID().uuidString,
        type: FiatTransactionType
    )
    -> FiatSceneViewModel {
        FiatSceneViewModel(fiatService: service, assetAddress: assetAddress, walletId: walletId, type: type)
    }

    @Test
    func testDefaultAmountText() {
        let buyText = FiatSceneViewModelTests.mock(type: .buy).amountText
        #expect(buyText == String(format: "%.0f", FiatTransactionTypeViewModel(type: .buy).defaultAmount))

        let sellText = FiatSceneViewModelTests.mock(type: .sell).amountText
        #expect(sellText == "0")
    }

    @Test
    func testAmountTextGetter() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        buyVM.input.amount = 150.0
        #expect(buyVM.amountText == "150")

        let sellVM = FiatSceneViewModelTests.mock(type: .sell)
        sellVM.input.amount = 0.005
        #expect(sellVM.amountText == "0.005")
    }

    @Test
    func testAmountTextSetterBuy() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        buyVM.amountText = "200"
        #expect(buyVM.input.amount == 200)

        let sellVM = FiatSceneViewModelTests.mock(type: .sell)
        sellVM.amountText = "0.005"
        #expect(sellVM.input.amount == 0.005)
    }

    @Test
    func testCurrencySymbol() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        #expect(buyVM.currencyInputConfig.currencySymbol == "$")

        let sellVM = FiatSceneViewModelTests.mock(type: .sell)
        #expect(sellVM.currencyInputConfig.currencySymbol == sellVM.asset.symbol)
    }

    @Test
    func testButtonsTitle() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        #expect(buyVM.buttonTitle(amount: 10.0) == "$10")

        let sellVM = FiatSceneViewModelTests.mock(type: .sell)
        #expect(sellVM.buttonTitle(amount: 1.3) == "1%")
    }

    @Test
    func testRateValue() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        let quote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 2.0, type: buyVM.input.type)

        #expect(buyVM.rateValue(for: quote) ==  "1 BTC ≈ $600.00")
    }

    @Test
    func testCryptoAmountValue() {
        let buyVM = FiatSceneViewModelTests.mock(type: .buy)
        let buyQuote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 1, type: buyVM.input.type)
        buyVM.input.quote = buyQuote
        #expect(buyVM.cryptoAmountValue == "≈ 1.00BTC")

        let sellVM = FiatSceneViewModelTests.mock(type: .sell)
        let sellQuote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 1, type: sellVM.input.type)
        sellVM.input.quote = sellQuote

        #expect(sellVM.cryptoAmountValue == "≈ 1,200.00$")
    }
}
