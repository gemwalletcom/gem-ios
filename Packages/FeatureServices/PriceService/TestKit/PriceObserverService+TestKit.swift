// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import Preferences
import PreferencesTestKit
import WebSocketClient
import WebSocketClientTestKit

public extension PriceObserverService {
    static func mock(
        priceService: PriceService = .mock(),
        preferences: Preferences = .mock(),
        webSocket: any WebSocketConnectable = WebSocketConnectionMock()
    ) -> PriceObserverService {
        PriceObserverService(
            priceService: priceService,
            preferences: preferences,
            webSocket: webSocket
        )
    }
}
