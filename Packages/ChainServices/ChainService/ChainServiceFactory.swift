// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

public final class ChainServiceFactory: Sendable {

    private let nodeProvider: any NodeURLFetchable

    public var requestInterceptor: any RequestInterceptable {
        nodeProvider.requestInterceptor
    }

    public init(nodeProvider: any NodeURLFetchable) {
        self.nodeProvider = nodeProvider
    }

    public func service(for chain: Chain) -> any ChainServiceable {
        ChainService.service(chain: chain, nodeProvider: nodeProvider)
    }
}
