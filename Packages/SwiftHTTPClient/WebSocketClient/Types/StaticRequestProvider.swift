// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct StaticRequestProvider: WebSocketRequestProvider {
    private let request: URLRequest

    public init(request: URLRequest) {
        self.request = request
    }

    public init(url: URL) {
        self.request = URLRequest(url: url)
    }

    public func makeRequest() -> URLRequest {
        request
    }
}
