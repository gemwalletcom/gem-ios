// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPosition {
    static func mock(
        id: String = "position_1",
        perpetualId: String = "hypercore_ETH-USD",
        assetId: AssetId = AssetId(chain: .ethereum, tokenId: nil),
        size: Double = 1.0,
        sizeValue: Double = 1000.0,
        leverage: UInt8 = 10,
        entryPrice: Double = 1000.0,
        liquidationPrice: Double? = nil,
        marginType: PerpetualMarginType = .isolated,
        direction: PerpetualDirection? = nil,
        marginAmount: Double = 100.0,
        takeProfit: PerpetualTriggerOrder? = nil,
        stopLoss: PerpetualTriggerOrder? = nil,
        pnl: Double = 0,
        funding: Float? = nil
    ) -> PerpetualPosition {
        let direction = direction ?? (size >= 0 ? .long : .short)

        return PerpetualPosition(
            id: id,
            perpetualId: perpetualId,
            assetId: assetId,
            size: size,
            sizeValue: sizeValue,
            leverage: leverage,
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: marginType,
            direction: direction,
            marginAmount: marginAmount,
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            pnl: pnl,
            funding: funding
        )
    }
}
