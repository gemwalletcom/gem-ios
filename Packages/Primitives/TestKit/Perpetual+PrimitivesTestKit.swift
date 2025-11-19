// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Perpetual {
    static func mock(
        id: String = "hypercore_ETH-USD",
        name: String = "ETH-USD",
        provider: PerpetualProvider = .hypercore,
        assetId: AssetId = AssetId(chain: .ethereum, tokenId: nil),
        price: Double = 1000.0,
        pricePercentChange24h: Double = 0,
        openInterest: Double = 1_000_000,
        volume24h: Double = 10_000_000,
        funding: Double = 0.0001,
        maxLeverage: UInt8 = 50
    ) -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            identifier: "0",
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            maxLeverage: maxLeverage
        )
    }
}
