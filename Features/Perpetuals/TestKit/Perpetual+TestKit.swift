// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Perpetual {
    static func mock(
        id: String = "test-perpetual",
        name: String = "BTC-USDT",
        provider: PerpetualProvider = .hypercore,
        assetId: AssetId = AssetId(chain: .bitcoin, tokenId: nil),
        price: Double = 50000,
        pricePercentChange24h: Double = 5.0,
        leverage: [UInt8] = [1, 5, 10, 25, 50],
        openInterest: Double = 1000000,
        volume24h: Double = 5000000,
        funding: Double = 0.01
    ) -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: leverage
        )
    }
}