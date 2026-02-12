// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectRelay

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        var request = URLRequest(url: url)
        request.addValue("gemwallet.com", forHTTPHeaderField: "Origin")
        return WebSocket(request: request)
    }
}
