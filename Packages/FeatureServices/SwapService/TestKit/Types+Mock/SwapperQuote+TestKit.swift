// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperQuote

public extension SwapperQuote {
    static func mock(
        fromValue: String = "1000000000000000000",
        toValue: String = "250000000000",
        etaInSeconds: UInt32? = nil
    ) -> SwapperQuote {
        SwapperQuote(
            fromValue: fromValue,
            toValue: toValue,
            data: .mock(),
            request: .mock(),
            etaInSeconds: etaInSeconds
        )
    }
}
