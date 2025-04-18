// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Duration {
    static func min(_ lhs: Duration, _ rhs: Duration) -> Duration {
        lhs < rhs ? lhs : rhs
    }

    static func max(_ lhs: Duration, _ rhs: Duration) -> Duration {
        lhs < rhs ? rhs : lhs
    }
}
