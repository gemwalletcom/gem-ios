// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WebSocketState: Sendable {
    case connecting
    case connected
    case reconnecting
    case disconnected
}
