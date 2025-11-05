// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.TpslOrderData {
    public func map() throws -> Primitives.TPSLOrderData {
        Primitives.TPSLOrderData(
            direction: direction.map(),
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            size: size
        )
    }
}

extension Primitives.TPSLOrderData {
    public func map() -> Gemstone.TpslOrderData {
        Gemstone.TpslOrderData(
            direction: direction.map(),
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            size: size
        )
    }
}
