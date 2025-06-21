// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

extension BalanceStore {
    public static func mock(db: DB = .mock()) -> Self {
        BalanceStore(db: db)
    }
}
