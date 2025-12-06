// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public actor ProviderMock: Sendable {

    private var responses: [String: Data] = [:]

    public init() {}

    public func setResponse(_ data: Data, for path: String) {
        responses[path] = data
    }

    public func response(for path: String) -> Data? {
        responses[path]
    }
}
