// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension ConnectionsStore {
    static func mock(
        db: DB = .mock()
    ) -> ConnectionsStore {
        ConnectionsStore(db: db)
    }
}
