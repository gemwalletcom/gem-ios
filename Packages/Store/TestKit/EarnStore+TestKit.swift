// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension EarnStore {
    static func mock(db: DB = .mock()) -> Self {
        EarnStore(db: db)
    }
}
