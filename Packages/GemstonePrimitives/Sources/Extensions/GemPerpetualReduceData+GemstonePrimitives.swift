// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.GemPerpetualReduceData {
    public func map() throws -> Primitives.PerpetualReduceData {
        Primitives.PerpetualReduceData(
            data: try data.map(),
            positionDirection: positionDirection.map()
        )
    }
}
