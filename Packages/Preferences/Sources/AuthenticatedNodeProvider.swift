// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AuthenticatedNodeProvider: NodeURLFetchable {
    private let nodeProvider: any NodeURLFetchable
    public let requestInterceptor: any RequestInterceptable

    public init(nodeProvider: any NodeURLFetchable, requestInterceptor: any RequestInterceptable) {
        self.nodeProvider = nodeProvider
        self.requestInterceptor = requestInterceptor
    }

    public func node(for chain: Chain) -> URL {
        nodeProvider.node(for: chain)
    }
}
