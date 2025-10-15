// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Components

struct ConfirmNetworkFeeViewModel: ItemModelProvidable {
    private let state: StateViewType<TransactionInputViewModel>
    private let title: String
    private let value: String?
    private let fiatValue: String?
    private let infoAction: VoidAction

    init(
        state: StateViewType<TransactionInputViewModel>,
        title: String,
        value: String?,
        fiatValue: String?,
        infoAction: VoidAction
    ) {
        self.state = state
        self.title = title
        self.value = value
        self.fiatValue = fiatValue
        self.infoAction = infoAction
    }
}

// MARK: - ItemModelProvidable

extension ConfirmNetworkFeeViewModel {
    var itemModel: ConfirmTransferItemModel {
        .networkFee(
            .init(
                title: title,
                subtitle: networkFeeValue,
                subtitleExtra: networkFeeFiatValue,
                placeholders: [.subtitle],
                infoAction: infoAction
            )
        )
    }
}

// MARK: - Private

extension ConfirmNetworkFeeViewModel {
    private var isCalculatorError: Bool {
        switch state.value?.transferAmount {
        case .success, .none: false
        case .failure: true
        }
    }

    private var networkFeeValue: String? {
        if state.isError { return "-" }
        if isCalculatorError { return value }
        return fiatValue ?? value
    }

    private var networkFeeFiatValue: String? {
        if isCalculatorError {
            return fiatValue
        }
        return nil
    }
}
