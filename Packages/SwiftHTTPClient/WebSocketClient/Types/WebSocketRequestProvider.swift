// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol WebSocketRequestProvider: Sendable {
    func makeRequest() throws -> URLRequest
}
