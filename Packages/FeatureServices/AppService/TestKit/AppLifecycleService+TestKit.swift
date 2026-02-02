// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import PreferencesTestKit
import DeviceService
import DeviceServiceTestKit
import PriceService
import PriceServiceTestKit
import PerpetualService
import PerpetualServiceTestKit
import ConnectionsService
import ConnectionsServiceTestKit
@testable import AppService

public extension AppLifecycleService {
    static func mock(
        preferences: Preferences = .mock(),
        connectionsService: ConnectionsService = .mock(),
        deviceObserverService: DeviceObserverService = .mock(),
        priceObserverService: PriceObserverService = .mock(),
        hyperliquidObserverService: PerpetualObserverMock = PerpetualObserverMock()
    ) -> AppLifecycleService {
        AppLifecycleService(
            preferences: preferences,
            connectionsService: connectionsService,
            deviceObserverService: deviceObserverService,
            priceObserverService: priceObserverService,
            hyperliquidObserverService: hyperliquidObserverService
        )
    }
}
