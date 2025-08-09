// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
import PrimitivesTestKit
import Formatters
import Style

@testable import PrimitivesComponents

struct NumericViewModelTests {
    let asset = Asset.mock()
    let price = Price.mock(price: 2.0)
    let value = BigInt(100_000_000)
    let style = AmountDisplayStyle(
        sign: .incoming,
        formatter: .full,
        currencyCode: "USD"
    )

    @Test
    func amountText() {
        let data = AssetValuePrice(asset: asset, value: value, price: price)
        let viewModel = NumericViewModel(data: data, style: style)
        
        #expect(viewModel.amount.text == "+1 BTC")
        #expect(viewModel.amount.style.color == Colors.green)
    }

    @Test
    func amountTextOutgoing() {
        let outgoingStyle = AmountDisplayStyle(
            sign: .outgoing,
            formatter: .full,
            currencyCode: "USD"
        )
        let data = AssetValuePrice(asset: asset, value: value, price: price)
        let viewModel = NumericViewModel(data: data, style: outgoingStyle)
        
        #expect(viewModel.amount.text == "-1 BTC")
        #expect(viewModel.amount.style.color == Colors.black)
    }

    @Test
    func amountTextNoSign() {
        let noSignStyle = AmountDisplayStyle(
            sign: .none,
            formatter: .full,
            currencyCode: "USD"
        )
        let data = AssetValuePrice(asset: asset, value: value, price: price)
        let viewModel = NumericViewModel(data: data, style: noSignStyle)
        
        #expect(viewModel.amount.text == "1 BTC")
        #expect(viewModel.amount.style.color == Colors.black)
    }

    @Test
    func fiatText() {
        let data = AssetValuePrice(asset: asset, value: value, price: price)
        let viewModel = NumericViewModel(data: data, style: style)
        
        #expect(viewModel.fiat?.text == "$2.00")
        #expect(viewModel.fiat?.style.color == Colors.gray)
    }

    @Test
    func fiatTextNilWhenPriceIsNil() {
        let data = AssetValuePrice(asset: asset, value: value, price: nil)
        let viewModel = NumericViewModel(data: data, style: style)
        
        #expect(viewModel.fiat == nil)
    }

    @Test
    func zeroValueNoSign() {
        let zeroStyle = AmountDisplayStyle(
            sign: .incoming,
            formatter: .full,
            currencyCode: "USD"
        )
        let data = AssetValuePrice(asset: asset, value: BigInt.zero, price: price)
        let viewModel = NumericViewModel(data: data, style: zeroStyle)
        
        #expect(viewModel.amount.text == "0 BTC")
    }
}