// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WebSocketConfiguration: Sendable {
    public let request: URLRequest
    public let reconnection: any Reconnectable
    public let sessionConfiguration: URLSessionConfiguration

    public init(
        request: URLRequest,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.request = request
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }

    public init(
        url: URL,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.request = URLRequest(url: url)
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }
}
