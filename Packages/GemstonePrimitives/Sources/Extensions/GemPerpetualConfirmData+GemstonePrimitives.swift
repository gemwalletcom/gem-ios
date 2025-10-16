// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualConfirmMetadata {
    public func map() -> Primitives.PerpetualConfirmMetadata {
        Primitives.PerpetualConfirmMetadata(
            slippage: slippage,
            leverage: leverage,
            pnl: pnl,
            entryPrice: entryPrice,
            marketPrice: marketPrice,
            marginAmount: marginAmount
        )
    }
}

extension Primitives.PerpetualConfirmMetadata {
    public func map() -> Gemstone.PerpetualConfirmMetadata {
        Gemstone.PerpetualConfirmMetadata(
            slippage: slippage,
            leverage: leverage,
            pnl: pnl,
            entryPrice: entryPrice,
            marketPrice: marketPrice,
            marginAmount: marginAmount
        )
    }
}

extension Gemstone.PerpetualConfirmData {
    public func map() throws -> Primitives.PerpetualConfirmData {
        Primitives.PerpetualConfirmData(
            direction: direction.map(),
            baseAsset: try baseAsset.map(),
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size,
            metadata: metadata.map()
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
            metadata: metadata.map()
        )
    }
}
