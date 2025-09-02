// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct TransactionSwapButtonViewModel {
    private let transaction: TransactionExtended

    public init(transaction: TransactionExtended) {
        self.transaction = transaction
    }

    public var itemModel: TransactionItemModel {
        guard case let .swap(metadata) = transaction.transaction.metadata,
              shouldShowSwapButton else {
            return TransactionItemModel.empty
        }

        return TransactionItemModel.swapAgain(
            text: Localized.Transaction.swapAgain
        )
    }

    private var shouldShowSwapButton: Bool {
        transaction.transaction.state == .confirmed
    }
}
