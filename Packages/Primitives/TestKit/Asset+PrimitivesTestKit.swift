// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Asset {
    static func mock(
        _ asset: Asset = Asset(
            id: .mock(),
            name: "Bitcoin",
            symbol: "BTC",
            decimals: 8,
            type: .native
        )
    ) -> Asset {
        asset
    }
}
