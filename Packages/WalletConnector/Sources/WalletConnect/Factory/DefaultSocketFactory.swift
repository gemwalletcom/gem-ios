// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Starscream
import Starscream
import WalletConnectRelay

extension WebSocket: @retroactive WebSocketConnecting { }

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        return WebSocket(request: URLRequest(url: url))
    }
}
