// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

class ChainSettingsViewModel: ObservableObject {
    
    let chain: Chain
    let nodeService: NodeService
    
    @Published var chainNode: ChainNode {
        didSet {
            try? nodeService.setNodeSelected(chain: chain, node: chainNode.node)
        }
    }
    @Published var nodes: [ChainNode] = []
    
    init(
        chain: Chain,
        nodeService: NodeService
    ) {
        self.chain = chain
        self.nodeService = nodeService
        self.chainNode = nodeService.getNodeSelected(chain: chain)
    }
    
    var title: String {
        return Asset(chain).name
    }
    
    func getNodes() throws -> [ChainNode] {
        return try nodeService.nodes(for: chain)
    }
}
