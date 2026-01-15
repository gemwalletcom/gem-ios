// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NotificationService
import GemAPI
import GemAPITestKit
import DeviceService
import DeviceServiceTestKit
import Store
import StoreTestKit

public extension InAppNotificationService {
    static func mock(
        apiService: GemAPINotificationService = GemAPINotificationServiceMock(),
        deviceService: DeviceServiceable = DeviceService.mock(),
        store: InAppNotificationStore = .mock()
    ) -> Self {
        InAppNotificationService(
            apiService: apiService,
            deviceService: deviceService,
            store: store
        )
    }
}
