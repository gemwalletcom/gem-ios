// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import Localization
import Components
import Style

struct ConfirmButtonViewModel: StateButtonViewable {
    let title: String
    let type: ButtonType
    let icon: Image?
    private let onAction: @MainActor @Sendable () -> Void

    func action() { onAction() }

    init(
        state: StateViewType<TransactionInputViewModel>,
        icon: Image? = nil,
        infoText: String? = nil,
        action: @MainActor @Sendable @escaping () -> Void
    ) {
        self.title = Self.title(state)
        self.type = Self.type(state)
        self.icon = icon
        self.onAction = action
    }

    private static func title(_ state: StateViewType<TransactionInputViewModel>) -> String {
        if state.isError { return Localized.Common.tryAgain }

        switch state.value?.transferAmount {
        case .success, .none: return Localized.Transfer.confirm
        case .failure: return Localized.Errors.insufficientFunds
        }
    }

    static func type(_ state: StateViewType<TransactionInputViewModel>) -> ButtonType {
        let isPrimary: Bool = {
            switch state {
            case .noData, .loading, .error: true
            case let .data(model): model.transferAmount?.isSuccess ?? false
            }
        }()
        return isPrimary ? .primary(state, isDisabled: state.isNoData) : .secondary
    }
}
