// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualModifyPositionType {
    public func map() throws -> Primitives.PerpetualModifyPositionType {
        switch self {
        case .tpsl(let data):
            .tpsl(try data.map())
        case .cancel(let orders):
            .cancel(try orders.map { try $0.map() })
        }
    }
}

extension Primitives.PerpetualModifyPositionType {
    public func map() -> Gemstone.PerpetualModifyPositionType {
        switch self {
        case .tpsl(let data):
            .tpsl(data.map())
        case .cancel(let orders):
            .cancel(orders.map { $0.map() })
        }
    }
}
