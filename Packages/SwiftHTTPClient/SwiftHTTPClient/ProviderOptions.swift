// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ProviderOptions<T: TargetType>: Sendable {
    public let baseUrl: URL?
    public let requestInterceptor: (@Sendable (inout URLRequest, T) throws -> Void)?

    public init(baseUrl: URL?, requestInterceptor: (@Sendable (inout URLRequest, T) throws -> Void)? = nil) {
        self.baseUrl = baseUrl
        self.requestInterceptor = requestInterceptor
    }
}
