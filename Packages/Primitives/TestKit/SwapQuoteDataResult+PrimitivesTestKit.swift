// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension SwapQuoteDataResult {
    static func mock() -> SwapQuoteDataResult {
        SwapQuoteDataResult(
            quote: .mock(),
            data: .mock()
        )
    }
}
