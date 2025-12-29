// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NodeService
import Primitives

public struct NodeImportRunner: AsyncRunnable {
    public let id = "node_import"

    private let nodeService: NodeService

    public init(nodeService: NodeService) {
        self.nodeService = nodeService
    }

    public func run() async throws {
        try nodeService.importDefaultNodes()
    }
}
