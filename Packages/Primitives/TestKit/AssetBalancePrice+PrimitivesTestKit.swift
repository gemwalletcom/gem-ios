// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension AssetBalancePrice {
    public static func mock(
        balance: Balance = .mock(),
        price: AssetPrice = .mock()
    ) -> AssetBalancePrice {
        AssetBalancePrice(
            balance: balance,
            price: price
        )
    }
}
