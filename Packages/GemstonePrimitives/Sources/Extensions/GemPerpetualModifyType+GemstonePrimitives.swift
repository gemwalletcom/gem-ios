// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualModifyType {
    public func map() throws -> Primitives.PerpetualModifyType {
        switch self {
        case .tp(let direction, let price, let size):
            .tp(direction: try direction.map(), price: price, size: size)
        case .sl(let direction, let price, let size):
            .sl(direction: try direction.map(), price: price, size: size)
        case .tpsl(let direction, let takeProfit, let stopLoss, let size):
            .tpsl(direction: try direction.map(), takeProfit: takeProfit, stopLoss: stopLoss, size: size)
        case .cancel(let orders):
            .cancel(orders: try orders.map { try $0.map() })
        }
    }
}

extension Primitives.PerpetualModifyType {
    public func map() -> Gemstone.PerpetualModifyType {
        switch self {
        case .tp(let direction, let price, let size):
            .tp(direction: direction.map(), price: price, size: size)
        case .sl(let direction, let price, let size):
            .sl(direction: direction.map(), price: price, size: size)
        case .tpsl(let direction, let takeProfit, let stopLoss, let size):
            .tpsl(direction: direction.map(), takeProfit: takeProfit, stopLoss: stopLoss, size: size)
        case .cancel(let orders):
            .cancel(orders: orders.map { $0.map() })
        }
    }
}

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
