// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Store
import Primitives
import Blockchain

public class NodeService {

    let provider: GemAPINodesService
    let nodeStore: NodeStore
    var requestedChains = Set<Chain>()
    
    init(
        provider: GemAPINodesService = GemAPIService(),
        nodeStore: NodeStore
    ) {
        self.provider = provider
        self.nodeStore = nodeStore
    }
    
    func getNodeSelected(chain: Chain) -> ChainNode {
        guard let node = try? nodeStore.selectedNode(chain: chain.rawValue) else {
            return chain.defaultChainNode
        }
        return node
    }
    
    func setNodeSelected(chain: Chain, node: Node) throws {
        if node.url.contains("gemnodes.com") {
            return try nodeStore.deleteNodeSelected(chain: chain.rawValue)
        }
        guard let recordNode = try nodeStore.nodeRecord(chain: chain, url: node.url) else {
            throw AnyError("Node node record")
        }
        try nodeStore.setNodeSelected(node: recordNode)
    }
    
    func nodes(for chain: Chain) throws -> [ChainNode] {
        let nodes = try nodeStore.nodes(chain: chain)
        return ([chain.defaultChainNode] + nodes).unique()
    }
    
    func updateNodes() async throws -> Int {
        let nodes = try await provider.getNodes()
        try nodeStore.addNodes(chainNodes: nodes.nodes)
        return Int(nodes.version)
    }
    
    func update(chain: Chain, force: Bool = false) throws {
        guard !requestedChains.contains(chain) else {
            return
        }
        //let nodes = try nodeStore.nodeRecords(chain: chain)
        requestedChains.insert(chain)
    }
}

extension NodeService: NodeURLFetchable  {
    public func node(for chain: Chain) -> URL {
        guard
            let node = try? nodeStore.selectedNode(chain: chain.rawValue),
            let url = URL(string: node.node.url) else {
                return chain.defaultBaseUrl
        }
        return url
    }
}
