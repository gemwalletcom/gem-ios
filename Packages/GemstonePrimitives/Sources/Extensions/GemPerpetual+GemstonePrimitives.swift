// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetual {
    public func map() throws -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: try PerpetualProvider(id: provider),
            assetId: try AssetId(id: assetId),
            identifier: identifier,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: [UInt8](leverage)
        )
    }
}