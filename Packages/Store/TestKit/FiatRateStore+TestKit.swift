// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension FiatRateStore {
    static func mock(db: DB = .mock()) -> Self {
        FiatRateStore(db: db)
    }
}
