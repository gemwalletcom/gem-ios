// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualConfirmData {
    static func mock(
        direction: PerpetualDirection = .long,
        asset: Asset = .mock(),
        assetIndex: Int = 0,
        price: String = "100",
        fiatValue: Double = 100.0,
        size: String = "1"
    ) -> PerpetualConfirmData {
        PerpetualConfirmData(
            direction: direction,
            asset: asset,
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size
        )
    }
}