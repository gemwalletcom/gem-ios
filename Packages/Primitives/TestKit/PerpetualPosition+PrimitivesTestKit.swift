// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPosition {
    static func mock(
        id: String = "position_1",
        perpetual_id: String = "hypercore_ETH-USD",
        size: Double = 1.0,
        leverage: UInt8 = 10,
        liquidation_price: Double? = nil,
        margin_type: PerpetualMarginType = .isolated,
        margin_amount: Double = 100.0,
        take_profit: PriceTarget? = nil,
        stop_loss: PriceTarget? = nil,
        pnl: Double = 0,
        funding: Float? = nil
    ) -> PerpetualPosition {
        PerpetualPosition(
            id: id,
            perpetual_id: perpetual_id,
            size: size,
            leverage: leverage,
            liquidation_price: liquidation_price,
            margin_type: margin_type,
            margin_amount: margin_amount,
            take_profit: take_profit,
            stop_loss: stop_loss,
            pnl: pnl,
            funding: funding
        )
    }
}
