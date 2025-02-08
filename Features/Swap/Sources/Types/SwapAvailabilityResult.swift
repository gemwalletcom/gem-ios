// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import struct Gemstone.SwapQuote

public struct SwapAvailabilityResult: Sendable {
    public let quote: SwapQuote
    public let allowance: Bool
    
    public init(quote: SwapQuote, allowance: Bool) {
        self.quote = quote
        self.allowance = allowance
    }
}
