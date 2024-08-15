// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension TransactionExtended {
    static func mock(
        transaction: Transaction = .mock()
    ) -> TransactionExtended {
        TransactionExtended(
            transaction: transaction,
            asset: .mock(),
            feeAsset: .mock(),
            price: .none,
            feePrice: .none,
            assets: []
        )
    }
}
