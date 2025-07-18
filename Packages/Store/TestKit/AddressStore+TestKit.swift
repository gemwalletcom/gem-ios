// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

extension AddressStore {
    public static func mock(db: DB = .mock()) -> Self {
        AddressStore(db: db)
    }
}