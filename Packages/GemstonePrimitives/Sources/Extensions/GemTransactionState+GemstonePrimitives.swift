// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives

extension Gemstone.TransactionState {
    public func map() -> Primitives.TransactionState {
        switch self {
        case .pending: .pending
        case .confirmed: .confirmed
        case .inTransit: .inTransit
        case .failed: .failed
        case .reverted: .reverted
        }
    }
}
