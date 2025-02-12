// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import struct Gemstone.SwapQuote

public struct SwapAvailabilityResult: Sendable {
    public let quote: SwapQuote
    
    public init(quote: SwapQuote) {
        self.quote = quote
    }
}
