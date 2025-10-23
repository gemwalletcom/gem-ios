// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualModifyType {
    public func map() throws -> Primitives.PerpetualModifyType {
        switch self {
        case .tpsl(let tpslData):
            let primitiveData = Primitives.TPSLOrderData(
                direction: tpslData.direction.map(),
                takeProfit: tpslData.takeProfit,
                stopLoss: tpslData.stopLoss,
                size: tpslData.size
            )
            return .tpsl(primitiveData)
        case .cancel(let orders):
            return .cancel(try orders.map { try $0.map() })
        }
    }
}

extension Primitives.PerpetualModifyType {
    public func map() -> Gemstone.PerpetualModifyType {
        switch self {
        case .tpsl(let data):
            let gemstoneData = Gemstone.TpslOrderData(
                direction: data.direction.map(),
                takeProfit: data.takeProfit,
                stopLoss: data.stopLoss,
                size: data.size
            )
            return .tpsl(gemstoneData)
        case .cancel(let orders):
            return .cancel(orders.map { $0.map() })
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
