// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Gemstone
import Primitives

public extension SwapQuote {
    var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }

    var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}

public extension GemQuoteAsset {
    init(asset: Asset) {
        self.init(
            id: asset.id.identifier,
            symbol: asset.symbol,
            decimals: UInt32(asset.decimals)
        )
    }
}
