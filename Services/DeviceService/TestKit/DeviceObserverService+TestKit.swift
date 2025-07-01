// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import Store
import StoreTestKit

public extension DeviceObserverService {
    static func mock(
        deviceSyncManager: DeviceSyncManager = .mock(),
        subscriptionsService: SubscriptionService = .mock(),
        subscriptionsObserver: SubscriptionsObserver = .mock()
    ) -> DeviceObserverService {
        DeviceObserverService(
            deviceSyncManager: deviceSyncManager,
            subscriptionsService: subscriptionsService,
            subscriptionsObserver: subscriptionsObserver
        )
    }
}
