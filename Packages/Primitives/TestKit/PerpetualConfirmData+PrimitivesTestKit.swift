// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualConfirmMetadata {
    static func mock(
        slippage: Double = 2.0,
        leverage: UInt8 = 3,
        pnl: Double? = nil,
        entryPrice: Double? = nil,
        marketPrice: Double = 100.0,
        marginAmount: Double = 33.33
    ) -> PerpetualConfirmMetadata {
        PerpetualConfirmMetadata(
            slippage: slippage,
            leverage: leverage,
            pnl: pnl,
            entryPrice: entryPrice,
            marketPrice: marketPrice,
            marginAmount: marginAmount
        )
    }
}

public extension PerpetualConfirmData {
    static func mock(
        direction: PerpetualDirection = .long,
        baseAsset: Asset = .mock(),
        assetIndex: Int32 = 0,
        price: String = "100",
        fiatValue: Double = 100.0,
        size: String = "1",
        metadata: PerpetualConfirmMetadata = .mock()
    ) -> PerpetualConfirmData {
        PerpetualConfirmData(
            direction: direction,
            baseAsset: baseAsset,
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size,
            metadata: metadata
        )
    }
}
