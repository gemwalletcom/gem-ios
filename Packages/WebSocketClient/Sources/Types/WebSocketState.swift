// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WebSocketState: Sendable {
    case disconnected
    case connecting
    case connected
    case reconnecting
}
