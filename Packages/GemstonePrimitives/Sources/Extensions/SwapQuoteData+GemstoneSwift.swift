// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import struct Gemstone.GemSwapQuoteData

public extension Gemstone.GemSwapQuoteData {
    func asPrimitive(quote: Primitives.SwapQuote) -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            to: to,
            value: value,
            data: data,
            memo: memo,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
