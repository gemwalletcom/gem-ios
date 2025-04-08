// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension PriceAlertData {
    static func mock(
        asset: Asset = .mock(),
        price: Price? = .mock(),
        priceAlert: PriceAlert = .mock()
    ) -> Self {
        PriceAlertData(
            asset: asset,
            price: price,
            priceAlert: priceAlert
        )
    }
}
