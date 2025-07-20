// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension TransactionExtended {
    static func mock(
        transaction: Transaction = .mock(),
        asset: Asset = .mock(),
        assets: [Asset] = [],
        fromAddress: AddressName? = nil,
        toAddress: AddressName? = nil
    ) -> TransactionExtended {
        TransactionExtended(
            transaction: transaction,
            asset: asset,
            feeAsset: .mock(),
            price: .none,
            feePrice: .none,
            assets: assets,
            prices: [],
            fromAddress: fromAddress,
            toAddress: toAddress
        )
    }
}
