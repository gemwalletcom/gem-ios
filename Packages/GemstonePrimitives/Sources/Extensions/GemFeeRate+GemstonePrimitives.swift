// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemFeeRate {
    public func map() throws -> FeeRate {
        return FeeRate(
            priority: try FeePriority(id: priority), 
            gasPriceType: try gasPriceType.map()
        )
    }
}