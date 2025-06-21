// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

extension AssetStore {
    public static func mock(db: DB = .mock()) -> Self {
        AssetStore(db: db)
    }
}
