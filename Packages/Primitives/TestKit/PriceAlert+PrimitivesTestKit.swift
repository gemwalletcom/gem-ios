// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PriceAlert {
    static func mock(
        assetId: AssetId = .mock(),
        currency: String = "USD",
        price: Double? = .none,
        pricePercentChange: Double? = .none,
        priceDirection: PriceAlertDirection? = .none,
        lastNotifiedAt: Date? = .none
    ) -> PriceAlert {
        PriceAlert(
            assetId: assetId,
            currency: currency,
            price: price,
            pricePercentChange: pricePercentChange,
            priceDirection: priceDirection,
            lastNotifiedAt: lastNotifiedAt
        )
    }
}
