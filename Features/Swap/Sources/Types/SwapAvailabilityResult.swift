// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import struct Gemstone.SwapQuote

public struct SwapAvailabilityResult: Sendable {
    public let quotes: [SwapQuote]
    
    public init(quotes: [SwapQuote]) {
        self.quotes = quotes
    }
}
