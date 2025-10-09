// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import GemAPI
import GemAPITestKit

public extension DeviceService {
    static func mock(
        deviceProvider: GemAPIDeviceService = GemAPIDeviceServiceMock(),
        subscriptionsService: SubscriptionService = .mock()
    ) -> DeviceService {
        DeviceService(
            deviceProvider: deviceProvider,
            subscriptionsService: subscriptionsService
        )
    }
}
