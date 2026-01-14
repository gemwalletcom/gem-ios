// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct TransactionSwapButtonViewModel {
    private let metadata: TransactionSwapMetadata?
    private let state: TransactionState

    public init(metadata: TransactionSwapMetadata?, state: TransactionState) {
        self.metadata = metadata
        self.state = state
    }
}

extension TransactionSwapButtonViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard metadata != nil, state == .confirmed else {
            return .empty
        }

        return TransactionItemModel.swapAgain(
            text: Localized.Transaction.swapAgain
        )
    }
}
