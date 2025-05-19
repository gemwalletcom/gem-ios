// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension BannerStore {
    static func mock(db: DB = .mock()) -> Self {
        BannerStore(db: db)
    }
}
