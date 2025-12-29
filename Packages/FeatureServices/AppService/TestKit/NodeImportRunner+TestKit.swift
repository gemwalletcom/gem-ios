// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import NodeService
import NodeServiceTestKit

public extension NodeImportRunner {
    static func mock(
        nodeService: NodeService = .mock()
    ) -> NodeImportRunner {
        NodeImportRunner(nodeService: nodeService)
    }
}
