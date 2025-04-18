// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import Primitives

public extension SwapQuoteData {
    func gasLimit() throws -> BigInt {
        if let gasLimit = gasLimit {
            return BigInt(stringLiteral: gasLimit)
        }
        throw AnyError("No gas limit")
    }

    func value() -> BigInt {
        BigInt(stringLiteral: value)
    }
}
