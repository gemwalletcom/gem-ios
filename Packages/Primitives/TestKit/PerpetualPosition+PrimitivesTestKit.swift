// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPosition {
    static func mock(
        id: String = "position_1",
        perpetualId: String = "hypercore_ETH-USD",
        size: Double = 1.0,
        sizeValue: Double = 1000.0,
        leverage: UInt8 = 10,
        liquidationPrice: Double? = nil,
        marginType: PerpetualMarginType = .isolated,
        marginAmount: Double = 100.0,
        takeProfit: PriceTarget? = nil,
        stopLoss: PriceTarget? = nil,
        pnl: Double = 0,
        funding: Float? = nil
    ) -> PerpetualPosition {
        PerpetualPosition(
            id: id,
            perpetualId: perpetualId,
            size: size,
            sizeValue: sizeValue,
            leverage: leverage,
            liquidationPrice: liquidationPrice,
            marginType: marginType,
            marginAmount: marginAmount,
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            pnl: pnl,
            funding: funding
        )
    }
}
