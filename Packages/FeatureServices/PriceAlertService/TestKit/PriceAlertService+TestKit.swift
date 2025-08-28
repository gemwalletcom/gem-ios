// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceAlertService
import StoreTestKit
import Store
import DeviceService
import DeviceServiceTestKit
import PriceService
import PriceServiceTestKit
import GemAPITestKit
import GemAPI

public extension PriceAlertService {
    static func mock(
        store: PriceAlertStore = .mock(),
        apiService: any GemAPIPriceAlertService = GemAPIPriceAlertServiceMock(),
        deviceService: any DeviceServiceable = DeviceServiceMock(),
        priceService: PriceService = .mock(),
        priceObserverService: PriceObserverService = .mock()
    ) -> PriceAlertService {
        PriceAlertService(
            store: store,
            apiService: apiService,
            deviceService: deviceService,
            priceObserverService: priceObserverService
        )
    }
}
