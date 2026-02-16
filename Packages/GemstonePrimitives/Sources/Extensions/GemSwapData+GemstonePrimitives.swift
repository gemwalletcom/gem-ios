// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemApprovalData
import struct Gemstone.GemSwapData
import struct Gemstone.GemSwapProviderData
import struct Gemstone.GemSwapQuote
import struct Gemstone.GemSwapQuoteData
import Primitives

public extension Gemstone.GemSwapData {
    func map() throws -> Primitives.SwapData {
        try Primitives.SwapData(
            quote: quote.map(),
            data: data.map()
        )
    }
}

public extension Primitives.SwapData {
    func map() -> Gemstone.GemSwapData {
        Gemstone.GemSwapData(
            quote: quote.map(),
            data: data.map()
        )
    }
}

