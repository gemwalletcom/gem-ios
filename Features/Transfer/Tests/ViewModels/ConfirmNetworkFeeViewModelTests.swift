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
            infoAction: {}
        )

        guard case .networkFee(let item, let selectable) = model.itemModel else { return }
        #expect(item.subtitle == fiatValue)
        #expect(selectable == true)
    }

    @Test
    func loadedWithoutFiat() {
        let value = "0.001 ETH"
        let model = ConfirmNetworkFeeViewModel(
            state: .data(.mock()),
            title: Localized.Transfer.networkFee,
            value: value,
            fiatValue: nil,
            infoAction: {}
        )

        guard case .networkFee(let item, let selectable) = model.itemModel else { return }
        #expect(item.subtitle == value)
        #expect(selectable == true)
    }

    @Test
    func error() {
        let model = ConfirmNetworkFeeViewModel(
            state: .error(AnyError("test")),
            title: Localized.Transfer.networkFee,
            value: nil,
            fiatValue: nil,
            infoAction: {}
        )

        guard case .networkFee(let item, let selectable) = model.itemModel else { return }
        #expect(item.subtitle == "-")
        #expect(selectable == false)
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
            infoAction: {}
        )

        guard case .networkFee(let item, let selectable) = model.itemModel else { return }
        #expect(item.subtitle == value)
        #expect(item.subtitleExtra == fiatValue)
        #expect(selectable == true)
    }
}

