// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension AssetStore {
    static func mock(db: DB) -> Self {
        AssetStore(db: db)
    }
}
