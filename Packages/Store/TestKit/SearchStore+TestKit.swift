// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

extension SearchStore {
    public static func mock(db: DB = .mock()) -> Self {
        SearchStore(db: db)
    }
}
