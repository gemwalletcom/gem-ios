// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NotificationService
import GemAPI
import GemAPITestKit
import DeviceService
import DeviceServiceTestKit
import Store
import StoreTestKit
import WalletService
import WalletServiceTestKit

public extension InAppNotificationService {
    static func mock(
        apiService: GemAPINotificationService = GemAPINotificationServiceMock(),
        deviceService: DeviceServiceable = DeviceService.mock(),
        walletService: WalletService = .mock(),
        store: InAppNotificationStore = .mock()
    ) -> Self {
        InAppNotificationService(
            apiService: apiService,
            deviceService: deviceService,
            walletService: walletService,
            store: store
        )
    }
}
