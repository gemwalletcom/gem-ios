// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension ContactStore {
    static func mock(db: DB = .mock()) -> Self {
        ContactStore(db: db)
    }
}
