// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import Primitives

public extension SwapQuoteData {
    func gasLimit() throws -> BigInt {
        if let gasLimit = gasLimit {
            return BigInt(stringLiteral: gasLimit)
        }
        throw AnyError("No gas limit")
    }

    func value() -> BigInt {
        BigInt(stringLiteral: value)
    }
}

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
            assetId: asset.id.identifier,
            symbol: asset.symbol,
            decimals: UInt32(asset.decimals)
        )
    }
}
