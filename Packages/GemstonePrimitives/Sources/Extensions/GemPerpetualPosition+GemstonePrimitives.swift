// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualPosition {
    public func map() throws -> PerpetualPosition {
        return PerpetualPosition(
            id: id,
            perpetualId: perpetualId,
            assetId: try AssetId(id: assetId),
            size: size,
            sizeValue: sizeValue,
            leverage: leverage,
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: marginType.map(),
            direction: direction.map(),
            marginAmount: marginAmount,
            takeProfit: takeProfit?.map(),
            stopLoss: stopLoss?.map(),
            pnl: pnl,
            funding: funding
        )
    }
}

extension PerpetualPosition {
    public func map() -> GemPerpetualPosition {
        GemPerpetualPosition(
            id: id,
            perpetualId: perpetualId,
            assetId: assetId.identifier,
            size: size,
            sizeValue: sizeValue,
            leverage: leverage,
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: marginType.map(),
            direction: direction.map(),
            marginAmount: marginAmount,
            takeProfit: takeProfit?.map(),
            stopLoss: stopLoss?.map(),
            pnl: pnl,
            funding: funding
        )
    }
}
