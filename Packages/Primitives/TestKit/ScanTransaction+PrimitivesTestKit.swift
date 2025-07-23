// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ScanTransaction {
    static func mock(malicious: Bool = false, memoRequired: Bool = false) -> Self {
        .init(isMalicious: malicious, isMemoRequired: memoRequired)
    }
}
