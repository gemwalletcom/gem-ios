// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Asset {
    static func mock(
        id: AssetId = .mock(),
        name: String = "Bitcoin",
        symbol: String = "BTC",
        decimals: Int32 = 8,
        type: AssetType = .native
    ) -> Asset {
        Asset(
            id: id,
            name: name,
            symbol: symbol,
            decimals: decimals,
            type: type
        )
    }
}
