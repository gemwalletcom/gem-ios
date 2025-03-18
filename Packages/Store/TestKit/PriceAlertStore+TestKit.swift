// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension PriceAlertStore {
    static func mock(
        db: DB = .mock()
    ) -> PriceAlertStore {
        PriceAlertStore(db: db)
    }
}
