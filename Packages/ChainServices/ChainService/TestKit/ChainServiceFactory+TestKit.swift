// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService
import Primitives
import PrimitivesTestKit

public extension ChainServiceFactory {
    static func mock(
        nodeProvider: any NodeURLFetchable = MockNodeURLFetchable()
    ) -> ChainServiceFactory {
        ChainServiceFactory(nodeProvider: nodeProvider)
    }
}
