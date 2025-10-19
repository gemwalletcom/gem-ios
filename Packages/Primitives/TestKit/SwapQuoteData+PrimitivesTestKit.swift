// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension SwapQuoteData {
    static func mock(
        quote: SwapQuote = .mock()
    ) -> SwapQuoteData {
        SwapQuoteData(
            to: "",
            dataType: .contract,
            value: "",
            data: "",
            memo: nil,
            approval: nil,
            gasLimit: ""
        )
    }
}
