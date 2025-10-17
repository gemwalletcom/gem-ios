// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualConfirmData {
    public func map() throws -> Primitives.PerpetualConfirmData {
        Primitives.PerpetualConfirmData(
            direction: direction.map(),
            baseAsset: try baseAsset.map(),
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size,
            slippage: slippage,
            leverage: leverage,
            pnl: pnl,
            entryPrice: entryPrice,
            marketPrice: marketPrice,
            marginAmount: marginAmount
        )
    }
}

extension Primitives.PerpetualConfirmData {
    public func map() -> Gemstone.PerpetualConfirmData {
        Gemstone.PerpetualConfirmData(
            direction: direction.map(),
            baseAsset: baseAsset.map(),
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size,
            slippage: slippage,
            leverage: leverage,
            pnl: pnl,
            entryPrice: entryPrice,
            marketPrice: marketPrice,
            marginAmount: marginAmount
        )
    }
}
