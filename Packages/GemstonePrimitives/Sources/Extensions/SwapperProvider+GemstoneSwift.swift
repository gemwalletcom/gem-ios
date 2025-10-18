// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives

public extension SwapProvider {
    func map() -> SwapperProvider {
        swapperProviderFromStr(s: rawValue)!
    }
}

public extension SwapperProvider {
    func asPrimitives() -> SwapProvider {
        SwapProvider(rawValue: swapperProviderToStr(provider: self))!
    }
}
