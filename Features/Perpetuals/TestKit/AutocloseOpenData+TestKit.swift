// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@testable import Perpetuals

extension AutocloseOpenData {
    static func mock(
        direction: PerpetualDirection = .long,
        marketPrice: Double = 100.0,
        leverage: UInt8 = 10,
        size: Double = 1.0,
        assetDecimals: Int32 = 8,
        takeProfit: String? = nil,
        stopLoss: String? = nil
    ) -> AutocloseOpenData {
        AutocloseOpenData(
            direction: direction,
            marketPrice: marketPrice,
            leverage: leverage,
            size: size,
            assetDecimals: assetDecimals,
            takeProfit: takeProfit,
            stopLoss: stopLoss
        )
    }
}
