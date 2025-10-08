// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.GemPerpetualMarginType {
    public func map() -> Primitives.PerpetualMarginType {
        switch self {
        case .cross: .cross
        case .isolated: .isolated
        }
    }
}

extension Primitives.PerpetualMarginType {
    public func map() -> Gemstone.GemPerpetualMarginType {
        switch self {
        case .cross: .cross
        case .isolated: .isolated
        }
    }
}
