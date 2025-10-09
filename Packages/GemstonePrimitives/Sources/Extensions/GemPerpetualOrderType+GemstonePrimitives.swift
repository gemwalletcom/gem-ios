// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.GemPerpetualOrderType {
    public func map() -> Primitives.PerpetualOrderType {
        switch self {
        case .market: .market
        case .limit: .limit
        }
    }
}

extension Primitives.PerpetualOrderType {
    public func map() -> Gemstone.GemPerpetualOrderType {
        switch self {
        case .market: .market
        case .limit: .limit
        }
    }
}
