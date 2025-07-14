// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public extension SwapQuoteData {
    func gasLimitBigInt() throws -> BigInt {
        if let gasLimit = self.gasLimit {
            return BigInt(stringLiteral: gasLimit)
        }
        throw AnyError("No gas limit")
    }

    //TODO: Rename to value
    func asValue() -> BigInt {
        BigInt(stringLiteral: value)
    }
}
