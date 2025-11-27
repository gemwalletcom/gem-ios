// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension RecentActivityStore {
    static func mock(db: DB = .mock()) -> Self {
        RecentActivityStore(db: db)
    }
}
