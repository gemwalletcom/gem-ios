// Copyright (c). Gem Wallet. All rights reserved.

import RecentActivityService
import Store
import StoreTestKit

public extension RecentActivityService {
    static func mock(
        store: RecentActivityStore = .mock()
    ) -> Self {
        RecentActivityService(store: store)
    }
}
