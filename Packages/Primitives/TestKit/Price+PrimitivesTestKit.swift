// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Price {
    static func mock(
        price: Double = 1.5,
        priceChangePercentage24h: Double = .zero,
        updatedAt: Date = .now
    ) -> Price {
        Price(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt
        )
    }
}
