// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.GemPerpetualTriggerOrder {
    public func map() -> Primitives.PerpetualTriggerOrder {
        PerpetualTriggerOrder(
            price: price,
            order_type: orderType.map(),
            order_id: orderId
        )
    }
}

extension Primitives.PerpetualTriggerOrder {
    public func map() -> Gemstone.GemPerpetualTriggerOrder {
        GemPerpetualTriggerOrder(
            price: price,
            orderType: order_type.map(),
            orderId: order_id
        )
    }
}
