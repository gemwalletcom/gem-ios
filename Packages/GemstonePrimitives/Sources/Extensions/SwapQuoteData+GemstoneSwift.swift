// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import struct Gemstone.SwapperQuoteData

public extension Gemstone.SwapperQuoteData {
    func map(quote: Primitives.SwapQuote) -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            to: to,
            value: value,
            data: data,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}
