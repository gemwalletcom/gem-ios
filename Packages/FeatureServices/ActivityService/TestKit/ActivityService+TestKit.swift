// Copyright (c). Gem Wallet. All rights reserved.

import ActivityService
import Store
import StoreTestKit

public extension ActivityService {
    static func mock(
        store: RecentActivityStore = .mock()
    ) -> Self {
        ActivityService(store: store)
    }
}
