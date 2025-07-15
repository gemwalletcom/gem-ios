// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import struct Gemstone.SwapperQuoteAsset
import Primitives

public extension SwapperQuoteAsset {
    init(asset: Asset) {
        self.init(
            id: asset.id.identifier,
            symbol: asset.symbol,
            decimals: UInt32(asset.decimals)
        )
    }
}
