// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WebSocketEvent: Sendable {
    case connected
    case disconnected(Error?)
    case message(Data)
}
