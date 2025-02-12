// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import BigInt
import Primitives

extension SwapProvider {
    public var name: String {
        swapProviderNameToString(provider: self)
    }
}

extension SwapQuoteData {
    public func gasLimit() throws -> BigInt {
        if let gasLimit = self.gasLimit {
            return BigInt(stringLiteral: gasLimit)
        }
        throw AnyError("No gas limit")
    }
    
    public func value() -> BigInt {
        BigInt(stringLiteral: value)
    }
}
