// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Perpetual {
    static func mock(
        id: String = "test-perpetual",
        name: String = "BTC-USDT",
        provider: PerpetualProvider = .hypercore,
        assetId: AssetId = AssetId(chain: .bitcoin, tokenId: nil),
        identifier: String = "0",
        price: Double = 50000,
        pricePercentChange24h: Double = 5.0,
        maxLeverage: UInt8 = 25,
        openInterest: Double = 1000000,
        volume24h: Double = 5000000,
        funding: Double = 0.01
    ) -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            identifier: identifier,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            maxLeverage: maxLeverage
        )
    }
}
