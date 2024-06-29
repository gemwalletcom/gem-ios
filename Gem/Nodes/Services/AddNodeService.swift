// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import GemstonePrimitives
import Store
import Primitives

struct AddNodeService {

    let nodeStore: NodeStore
    
    func addNodes() throws {
        let configNodes = Config.shared.getNodes().map { (key, values) in
            ChainNodes(chain: key, nodes: values.map{ $0.node })
        }
        //let existingNodes = try nodeStore.nodes()
        //TODO: Remove outdated nodes (that does not exist in config nodes, except custom added nodes)
        
        try nodeStore.addNodes(chainNodes: configNodes)
    }

    func addNode(_ node: ChainNodes) throws {
        try nodeStore.addNodes(chainNodes: [node])
    }
}

extension Gemstone.Node {
    var node: Primitives.Node {
        let priority = switch priority {
        case .high: 10
        case .medium: 5
        case .low: 1
        case .inactive: -1
        }
        let status: NodeStatus = priority > 0 ? .active : .inactive
        
        return Primitives.Node(
            url: url,
            status: status,
            priority: priority.asInt32
        )
    }
}
