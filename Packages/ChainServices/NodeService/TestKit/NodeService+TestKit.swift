// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NodeService
import Store
import StoreTestKit

public extension NodeService {
    static func mock(
        nodeStore: NodeStore = .mock()
    ) -> NodeService {
        NodeService(nodeStore: nodeStore)
    }
}
