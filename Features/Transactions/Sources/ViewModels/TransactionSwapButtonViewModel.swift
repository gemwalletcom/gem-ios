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
        guard case let .swap(metadata) = transaction.transaction.metadata else {
            return .empty
        }

        return .swapButton(
            text: Localized.Transaction.swapAgain,
            url: DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        )
    }
}
