// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public extension SwapQuote {
    var toAmountBigInt: BigInt {
        BigInt(stringLiteral: self.toAmount)
    }
}
