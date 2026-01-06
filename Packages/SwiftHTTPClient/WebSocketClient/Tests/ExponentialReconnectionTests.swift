// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import WebSocketClient

struct ExponentialReconnectionTests {

    @Test
    func reconnectAfterWithDefaultMultiplier() {
        let reconnection = ExponentialReconnection(multiplier: 0.3, maxDelay: 10)

        #expect(reconnection.reconnectAfter(attempt: 0) == 0.3 * exp(0))
        #expect(reconnection.reconnectAfter(attempt: 1) == 0.3 * exp(1))
        #expect(reconnection.reconnectAfter(attempt: 2) == 0.3 * exp(2))
        #expect(reconnection.reconnectAfter(attempt: 10) == 10)
        #expect(reconnection.reconnectAfter(attempt: 100) == 10)
    }
}
