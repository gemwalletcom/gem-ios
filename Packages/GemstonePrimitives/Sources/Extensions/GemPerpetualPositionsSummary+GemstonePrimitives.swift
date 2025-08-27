// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualPositionsSummary {
    public func map() throws -> PerpetualPositionsSummary {
        PerpetualPositionsSummary(
            positions: try positions.map { try $0.map() },
            balance: balance.map()
        )
    }
}