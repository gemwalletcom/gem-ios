// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceAlertService
import StoreTestKit
import Store
import DeviceService
import DeviceServiceTestKit
import PriceService
import PriceServiceTestKit

public extension PriceAlertService {
    static func mock(
        store: PriceAlertStore = .mock(),
        deviceService: DeviceService = .mock(),
        priceService: PriceService = .mock()
    ) -> PriceAlertService {
        PriceAlertService(
            store: store,
            deviceService: deviceService,
            priceService: priceService
        )
    }
}
