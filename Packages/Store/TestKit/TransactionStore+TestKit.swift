// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension TransactionStore {
    static func mock(db: DB = .mock()) -> TransactionStore {
        TransactionStore(db: db)
    }
}
