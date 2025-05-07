// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Starscream
import WalletConnectRelay

extension WebSocket: @retroactive WebSocketConnecting { }

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("gemwallet.com", forHTTPHeaderField: "Origin")
        
        return WebSocket(request: urlRequest)
    }
}
