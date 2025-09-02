// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Localization
import Primitives

public struct TransactionStatusItemModel: ListItemViewable {
    private let state: TransactionState
    private let onInfoAction: (() -> Void)?

    public init(
        state: TransactionState,
        onInfoAction: (() -> Void)? = nil
    ) {
        self.state = state
        self.onInfoAction = onInfoAction
    }

    private var statusViewModel: TransactionStateViewModel {
        TransactionStateViewModel(state: state)
    }

    public var listItemModel: ListItemType {
        .custom(
            ListItemConfiguration(
                title: Localized.Transaction.status,
                titleTagType: state == .pending ? .progressView() : .image(statusViewModel.stateImage),
                subtitle: statusViewModel.title,
                subtitleStyle: TextStyle(font: .callout, color: statusViewModel.color),
                infoAction: onInfoAction
            )
        )
    }
}
