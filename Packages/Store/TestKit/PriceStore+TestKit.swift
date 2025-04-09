// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension PriceStore {
    static func mock(db: DB = .mock()) -> Self {
        PriceStore(db: db)
    }
}
