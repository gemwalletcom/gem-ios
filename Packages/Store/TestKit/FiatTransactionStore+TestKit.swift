// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension FiatTransactionStore {
    static func mock(db: DB = .mock()) -> Self {
        FiatTransactionStore(db: db)
    }
}
