// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct TransactionSwapButtonViewModel {
    private let transaction: TransactionExtended

    public init(transaction: TransactionExtended) {
        self.transaction = transaction
    }
}

// MARK: - ItemModelProvidable

extension TransactionSwapButtonViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard case .swap(_) = transaction.transaction.metadata,
              transaction.transaction.state == .confirmed else {
            return .empty
        }

        return TransactionItemModel.swapAgain(
            text: Localized.Transaction.swapAgain
        )
    }
}
