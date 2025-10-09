// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPosition {
    static func mock(
        id: String = "test-id",
        perpetualId: String = "test-perpetual-id",
        assetId: AssetId = AssetId(chain: .bitcoin, tokenId: nil),
        size: Double = 100,
        sizeValue: Double = 5000,
        leverage: UInt8 = 10,
        entryPrice: Double? = 50000,
        liquidationPrice: Double? = 45000,
        marginType: PerpetualMarginType = .isolated,
        direction: PerpetualDirection? = nil,
        marginAmount: Double = 500,
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
