// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol RequestInterceptable: Sendable {
    func intercept(request: inout URLRequest)
}

public struct EmptyRequestInterceptor: RequestInterceptable {
    public init() {}
    public func intercept(request: inout URLRequest) {}
}
