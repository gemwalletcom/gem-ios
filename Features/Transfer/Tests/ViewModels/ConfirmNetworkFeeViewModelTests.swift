// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Localization
@testable import Transfer
@testable import Primitives
import PrimitivesTestKit
import TransferTestKit
import Validators

struct ConfirmNetworkFeeViewModelTests {

    @Test
    func loaded() {
        let fiatValue = "$2.50"
        let model = ConfirmNetworkFeeViewModel(
            state: .data(.mock()),
            title: Localized.Transfer.networkFee,
            value: "0.001 ETH",
            fiatValue: fiatValue,
            showFeeRatesSelector: false,
            infoAction: {}
        )

        guard case .networkFee(let item, let selectable) = model.itemModel else { return }
        #expect(item.subtitle == fiatValue)
        #expect(selectable == false)
    }

    @Test
    func loadedWithoutFiat() {
        let value = "0.001 ETH"
        let model = ConfirmNetworkFeeViewModel(
            state: .data(.mock()),
            title: Localized.Transfer.networkFee,
            value: value,
            fiatValue: nil,
            showFeeRatesSelector: false,
            infoAction: {}
        )

        guard case .networkFee(let item, _) = model.itemModel else { return }
        #expect(item.subtitle == value)
    }

    @Test
    func error() {
        let model = ConfirmNetworkFeeViewModel(
            state: .error(AnyError("test")),
            title: Localized.Transfer.networkFee,
            value: nil,
            fiatValue: nil,
            showFeeRatesSelector: false,
            infoAction: {}
        )

        guard case .networkFee(let item, _) = model.itemModel else { return }
        #expect(item.subtitle == "-")
    }

    @Test
    func calculatorError() {
        let value = "0.001 ETH"
        let fiatValue = "$2.50"
        let input = TransactionInputViewModel(
            data: .mock(),
            transactionData: .mock(),
            metaData: nil,
            transferAmount: .failure(.insufficientBalance(.mock()))
        )
        let model = ConfirmNetworkFeeViewModel(
            state: .data(input),
            title: Localized.Transfer.networkFee,
            value: value,
            fiatValue: fiatValue,
            showFeeRatesSelector: false,
            infoAction: {}
        )

        guard case .networkFee(let item, _) = model.itemModel else { return }
        #expect(item.subtitle == value)
        #expect(item.subtitleExtra == fiatValue)
    }

    @Test
    func selectable() {
        let model = ConfirmNetworkFeeViewModel(
            state: .data(.mock()),
            title: "Fee",
            value: "0.001",
            fiatValue: nil,
            showFeeRatesSelector: true,
            infoAction: {}
        )

        guard case .networkFee(_, let selectable) = model.itemModel else { return }
        #expect(selectable == true)
    }
}

