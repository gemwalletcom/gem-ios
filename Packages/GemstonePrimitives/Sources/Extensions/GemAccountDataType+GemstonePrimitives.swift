// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemAccountDataType {
    public func map() -> AccountDataType {
        switch self {
        case .activate:
            return .activate
        }
    }
}

extension AccountDataType {
    public func map() -> GemAccountDataType {
        switch self {
        case .activate:
            return .activate
        }
    }
}
