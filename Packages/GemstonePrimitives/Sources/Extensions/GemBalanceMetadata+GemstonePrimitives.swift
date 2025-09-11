// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemBalanceMetadata {
    public func map() -> BalanceMetadata {
        BalanceMetadata(
            energyAvailable: energyAvailable,
            energyTotal: energyTotal,
            bandwidthAvailable: bandwidthAvailable,
            bandwidthTotal: bandwidthTotal
        )
    }
}
