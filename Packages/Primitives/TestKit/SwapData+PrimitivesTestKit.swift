// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapData {
    public static func mock(
        quote: SwapQuote = .mock(),
        data: SwapQuoteData = .mock()
    ) -> SwapData {
        SwapData(quote: quote, data: data)
    }
}