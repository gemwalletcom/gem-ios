// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualDirection {
    public func map() -> Primitives.PerpetualDirection {
        switch self {
        case .short: .short
        case .long: .long
        }
    }
}

extension Primitives.PerpetualDirection {
    public func map() -> Gemstone.PerpetualDirection {
        switch self {
        case .short: .short
        case .long: .long
        }
    }
}
