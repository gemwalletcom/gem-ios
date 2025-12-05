// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol WebSocketConnectable: Actor {
    var state: WebSocketState { get }

    func connect() -> AsyncStream<WebSocketEvent>
    func disconnect() async
    func send(_ data: Data) async throws
}
