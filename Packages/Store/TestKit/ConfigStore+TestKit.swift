// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension ConfigStore {
    static func mock(db: DB = .mock()) -> Self {
        ConfigStore(db: db)
    }
}
