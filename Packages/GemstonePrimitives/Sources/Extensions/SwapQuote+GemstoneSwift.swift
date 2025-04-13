// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone

public extension SwapQuote {
    var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }

    var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}
