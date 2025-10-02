// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemBalanceMetadata {
    public func map() -> BalanceMetadata {
        BalanceMetadata(
            votes: votes,
            energyAvailable: energyAvailable,
            energyTotal: energyTotal,
            bandwidthAvailable: bandwidthAvailable,
            bandwidthTotal: bandwidthTotal
        )
    }
}
