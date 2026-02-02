// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WebSocketConfiguration: Sendable {
    public let requestProvider: any WebSocketRequestProvider
    public let reconnection: any Reconnectable
    public let sessionConfiguration: URLSessionConfiguration

    public init(
        requestProvider: any WebSocketRequestProvider,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.requestProvider = requestProvider
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }

    public init(
        request: URLRequest,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.requestProvider = StaticRequestProvider(request: request)
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }

    public init(
        url: URL,
        reconnection: any Reconnectable = ExponentialReconnection(),
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.requestProvider = StaticRequestProvider(url: url)
        self.reconnection = reconnection
        self.sessionConfiguration = sessionConfiguration
    }
}
