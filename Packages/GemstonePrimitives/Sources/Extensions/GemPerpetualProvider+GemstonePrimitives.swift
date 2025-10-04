// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualProvider {
    public func map() -> Primitives.PerpetualProvider {
        switch self {
        case .hypercore: .hypercore
        }
    }
}

extension Primitives.PerpetualProvider {
    public func map() -> Gemstone.PerpetualProvider {
        switch self {
        case .hypercore: .hypercore
        }
    }
}
