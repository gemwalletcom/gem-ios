// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapQuoteData {
    public static func mock(
        quote: SwapQuote = .mock()
    ) -> SwapQuoteData {
        SwapQuoteData(
            quote: quote,
            to: "",
            value: "",
            data: "",
            approval: .none,
            gasLimit: ""
        )
    }
}
