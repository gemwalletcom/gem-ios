// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Perpetual {
    static func mock(
        id: String = "hypercore_ETH-USD",
        name: String = "ETH-USD",
        provider: PerpetualProvider = .hypercore,
        asset_id: AssetId = AssetId(chain: .ethereum, tokenId: nil),
        price: Double = 1000.0,
        price_percent_change_24h: Double = 0,
        open_interest: Double = 1_000_000,
        volume_24h: Double = 10_000_000,
        leverage: [UInt8] = [10, 20, 50]
    ) -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: provider,
            asset_id: asset_id,
            price: price,
            price_percent_change_24h: price_percent_change_24h,
            open_interest: open_interest,
            volume_24h: volume_24h,
            leverage: leverage
        )
    }
}