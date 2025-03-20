// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceAlertService
import StoreTestKit
import Store
import DeviceService
import DeviceServiceTestKit

public extension PriceAlertService {
    static func mock(
        store: PriceAlertStore = .mock(),
        deviceService: DeviceService = .mock()
    ) -> PriceAlertService {
        PriceAlertService(
            store: store,
            deviceService: deviceService
        )
    }
}
