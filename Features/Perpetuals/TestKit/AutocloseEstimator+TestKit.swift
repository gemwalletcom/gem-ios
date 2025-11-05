// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Perpetuals

public extension AutocloseEstimator {
    static func mock(
        entryPrice: Double = 100.0,
        positionSize: Double = 10.0,
        direction: PerpetualDirection = .long,
        leverage: UInt8 = 5
    ) -> AutocloseEstimator {
        AutocloseEstimator(
            entryPrice: entryPrice,
            positionSize: positionSize,
            direction: direction,
            leverage: leverage
        )
    }
}
