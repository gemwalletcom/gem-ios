// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Gemstone

extension SwapQuote {
    public var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }
    
    public var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}
