// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style

struct TransactionStatusViewModel {
    private let state: TransactionState
    private let onInfoAction: VoidAction

    init(
        state: TransactionState,
        onInfoAction: VoidAction
    ) {
        self.state = state
        self.onInfoAction = onInfoAction
    }

    private var stateViewModel: TransactionStateViewModel {
        TransactionStateViewModel(state: state)
    }
}

// MARK: - ItemModelProvidable

extension TransactionStatusViewModel: ItemModelProvidable {
    var itemModel: TransactionItemModel {
        .listItem(ListItemModel(
            title: Localized.Transaction.status,
            titleTagType: state == .pending ? .progressView() : .image(stateViewModel.stateImage),
            subtitle: stateViewModel.title,
            subtitleStyle: TextStyle(font: .callout, color: stateViewModel.color),
            infoAction: onInfoAction
        ))
    }
}
