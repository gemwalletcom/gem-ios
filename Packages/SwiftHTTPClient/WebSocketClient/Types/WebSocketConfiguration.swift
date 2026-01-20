// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WebSocketConfiguration: Sendable {
    public let url: URL
    public let reconnection: any Reconnectable
    public let sessionConfiguration: URLSessionConfiguration

    public init(
        url: URL,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.url = url
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }
}
