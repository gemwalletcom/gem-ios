// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualBalance {
    public func map() -> PerpetualBalance {
        PerpetualBalance(
            available: available,
            reserved: reserved,
            withdrawable: withdrawable
        )
    }
}