// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualPosition {
    public func map() throws -> PerpetualPosition {
        return PerpetualPosition(
            id: symbol,
            perpetualId: perpetualId,
            assetId: try AssetId(id: assetId),
            size: size,
            sizeValue: size * entryPrice,
            leverage: UInt8(leverage),
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: try PerpetualMarginType(id: marginType),
            direction: try PerpetualDirection(id: direction),
            marginAmount: margin,
            takeProfit: nil,
            stopLoss: nil,
            pnl: pnl,
            funding: funding
        )
    }
}
