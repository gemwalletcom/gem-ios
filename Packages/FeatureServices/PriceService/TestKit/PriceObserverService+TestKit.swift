// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import Preferences
import PreferencesTestKit
import WebSocketClientTestKit

public extension PriceObserverService {
    static func mock(
        priceService: PriceService = .mock(),
        preferences: Preferences = .mock()
    ) -> PriceObserverService {
        PriceObserverService(
            webSocket: WebSocketConnectionMock(),
            priceService: priceService,
            preferences: preferences
        )
    }
}
