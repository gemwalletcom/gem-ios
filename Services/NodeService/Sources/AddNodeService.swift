// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import class Gemstone.Config

public struct AddNodeService {
    public let nodeStore: NodeStore

    public init(nodeStore: NodeStore) {
        self.nodeStore = nodeStore
    }

    public func addNodes() throws {
        let configNodes = Config.shared.getNodes().map { (key, values) in
            ChainNodes(chain: key, nodes: values.map{ $0.node })
        }
        //let existingNodes = try nodeStore.nodes()
        //TODO: Remove outdated nodes (that does not exist in config nodes, except custom added nodes)
        
        try nodeStore.addNodes(chainNodes: configNodes)
    }

    public func addNode(_ node: ChainNodes) throws {
        try nodeStore.addNodes(chainNodes: [node])
    }
}
