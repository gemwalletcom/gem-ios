// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NodeService
import Primitives

public struct NodeImportRunner: OnstartAsyncRunnable {
    private let nodeService: NodeService

    public init(nodeService: NodeService) {
        self.nodeService = nodeService
    }

    public func run(config: ConfigResponse?) async throws {
        try nodeService.importDefaultNodes()
    }
}
