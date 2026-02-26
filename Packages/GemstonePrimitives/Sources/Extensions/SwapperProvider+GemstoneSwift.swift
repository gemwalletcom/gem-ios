// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives

public extension SwapProvider {
    func map() throws -> SwapperProvider {
        try swapperProviderFromStr(s: rawValue).unwrapOrThrow()
    }
}

public extension SwapperProvider {
    func map() throws -> SwapProvider {
        try SwapProvider(rawValue: swapperProviderToStr(provider: self)).unwrapOrThrow()
    }
}
