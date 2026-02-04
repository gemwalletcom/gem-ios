// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension StakeStore {
    static func mock(db: DB = .mock()) -> Self {
        StakeStore(db: db)
    }
}
