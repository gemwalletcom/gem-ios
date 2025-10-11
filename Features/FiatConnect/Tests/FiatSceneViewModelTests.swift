// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import GemAPI
import Primitives
import Formatters

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
        let model = FiatSceneViewModelTests.mock()
        #expect(model.inputValidationModel.text == String(format: "%.0f", FiatQuoteTypeViewModel(type: .buy).defaultAmount))

        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)

        #expect(model.inputValidationModel.text == "")
    }

    @Test
    func testStatesChanges() {
        let model = FiatSceneViewModelTests.mock()
        model.onChangeAmountText("", text: "100")

        #expect(model.input.type == .buy)
        #expect(model.input.amount == 100)

        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)

        #expect(model.input.type == .sell)
        #expect(model.input.amount != 100)

        model.onChangeAmountText("", text: "200")

        model.input.type = .buy
        model.onChangeType(.sell, type: .buy)

        #expect(model.input.amount == 100)
    }

    @Test
    func testSelectBuyAmount() {
        let model = FiatSceneViewModelTests.mock()
        model.onSelect(amount: 150)

        #expect(model.inputValidationModel.text == "150")

        model.onSelect(amount: 1.1)

        #expect(model.inputValidationModel.text != "1.1")
        #expect(model.inputValidationModel.text == "1")
    }

    @Test
    func testSelectSellAmount() {
        let model = FiatSceneViewModelTests.mock()
        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)
        model.assetData = .mock(balance: Balance(available: 100_000.asBigInt))

        model.onSelect(amount: 50)

        #expect(model.inputValidationModel.text == "0.0005")

        model.onSelect(amount: 100)

        #expect(model.inputValidationModel.text == "0.001")
    }

    @Test
    func testCurrencySymbol() {
        let model = FiatSceneViewModelTests.mock()
        #expect(model.currencyInputConfig.currencySymbol == "$")

        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)

        #expect(model.currencyInputConfig.currencySymbol == model.asset.symbol)
    }

    @Test
    func testButtonsTitle() {
        let model = FiatSceneViewModelTests.mock()

        #expect(model.buttonTitle(amount: 10.0) == "$10")

        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)

        #expect(model.buttonTitle(amount: 1.3) == "1%")
    }

    @Test
    func testRateValue() {
        let model = FiatSceneViewModelTests.mock()
        let quote = FiatQuote.mock(fiatAmount: 1200, cryptoAmount: 2.0, type: model.input.type)

        #expect(model.rateValue(for: quote) == "1 \(model.asset.symbol) ≈ $600.00")
    }

    @Test
    func testCryptoAmountValue() {
        let model = FiatSceneViewModelTests.mock()
        let buyQuote = FiatQuote.mock(fiatAmount: 0, cryptoAmount: 1, type: model.input.type)
        model.input.quote = buyQuote
        #expect(model.cryptoAmountValue == "≈ 1.00 \(model.asset.symbol)")

        model.input.type = .sell
        model.onChangeType(.buy, type: .sell)
        let sellQuote = FiatQuote.mock(fiatAmount: 2400, cryptoAmount: 1, type: model.input.type)
        model.input.quote = sellQuote

        #expect(model.cryptoAmountValue == "≈ $2,400.00")
    }

    @Test
    func testFiatValidation() {
        let model = FiatSceneViewModelTests.mock()
        
        model.inputValidationModel.text = "4"
        #expect(model.inputValidationModel.update() == false)
        
        model.inputValidationModel.text = "5"
        #expect(model.inputValidationModel.update() == true)
        
        model.inputValidationModel.text = "10000"
        #expect(model.inputValidationModel.update() == true)
        
        model.inputValidationModel.text = "10001"
        #expect(model.inputValidationModel.update() == false)
    }
}
