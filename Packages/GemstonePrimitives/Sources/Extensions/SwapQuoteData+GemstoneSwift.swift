// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public extension SwapperQuoteData {
    func asPrimitive(quote: Primitives.SwapQuote) -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            to: to,
            value: value,
            data: data,
            approval: approval?.asPrimitive,
            gasLimit: gasLimit
        )
    }
}
