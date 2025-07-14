// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public extension Gemstone.SwapQuoteData {
    func asPrimitive(quote: Primitives.SwapQuote) -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            quote: quote,
            to: to,
            value: value,
            data: data,
            approval: approval?.asPrimitive,
            gasLimit: gasLimit
        )
    }
}
