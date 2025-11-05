// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.CancelOrderData {
    public func map() throws -> Primitives.CancelOrderData {
        Primitives.CancelOrderData(assetIndex: assetIndex, orderId: orderId)
    }
}

extension Primitives.CancelOrderData {
    public func map() -> Gemstone.CancelOrderData {
        Gemstone.CancelOrderData(assetIndex: assetIndex, orderId: orderId)
    }
}
