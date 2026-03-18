// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperQuote

public enum SwapQuoteStreamEvent: Sendable {
    case started(totalProviders: Int)
    case result(Result<SwapperQuote, Error>)
}
