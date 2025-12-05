// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WebSocketConfiguration: Sendable {
    public let url: URL
    public let reconnectDelay: TimeInterval
    public let maxReconnectDelay: TimeInterval
    public let sessionConfiguration: URLSessionConfiguration

    public init(
        url: URL,
        reconnectDelay: TimeInterval = 1,
        maxReconnectDelay: TimeInterval = 30,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.url = url
        self.reconnectDelay = reconnectDelay
        self.maxReconnectDelay = maxReconnectDelay
        self.sessionConfiguration = sessionConfiguration
    }
}
