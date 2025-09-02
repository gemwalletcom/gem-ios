// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style

public struct TransactionStatusViewModel: Sendable {
    private let state: TransactionState
    private let onInfoAction: (@MainActor @Sendable () -> Void)?

    public init(
        state: TransactionState,
        onInfoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.state = state
        self.onInfoAction = onInfoAction
    }
    
    private var stateViewModel: TransactionStateViewModel {
        TransactionStateViewModel(state: state)
    }
    
    public var itemModel: TransactionStatusItemModel {
        TransactionStatusItemModel(
            title: Localized.Transaction.status,
            titleTagType: state == .pending ? .progressView() : .image(stateViewModel.stateImage),
            subtitle: stateViewModel.title,
            subtitleStyle: TextStyle(font: .callout, color: stateViewModel.color),
            infoAction: onInfoAction
        )
    }
}
