// Copyright (c). Gem Wallet. All rights reserved.

import BannerService
import Store
import StoreTestKit
import NotificationService
import NotificationServiceTestKit

public extension BannerService {
    static func mock(
        store: BannerStore = .mock(),
        pushNotificationService: PushNotificationEnablerService = .mock()
    ) -> Self {
        BannerService(
            store: store,
            pushNotificationService: pushNotificationService
        )
    }
}
