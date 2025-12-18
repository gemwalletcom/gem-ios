// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualTransferData {
    static func mock(
        provider: PerpetualProvider = .hypercore,
        direction: PerpetualDirection = .long,
        asset: Asset = .mock(),
        baseAsset: Asset = .mock(),
        assetIndex: Int = 0,
        price: Double = 100.0,
        leverage: UInt8 = 3
    ) -> PerpetualTransferData {
        PerpetualTransferData(
            provider: provider,
            direction: direction,
            asset: asset,
            baseAsset: baseAsset,
            assetIndex: assetIndex,
            price: price,
            leverage: leverage
        )
    }
}
