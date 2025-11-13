// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.ScanTransaction {
    public func map() throws -> Primitives.ScanTransaction {
        Primitives.ScanTransaction(
            isMalicious: isMalicious,
            isMemoRequired: isMemoRequired
        )
    }
}
