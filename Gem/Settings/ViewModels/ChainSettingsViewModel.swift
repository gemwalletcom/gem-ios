// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives

class ChainSettingsViewModel: ObservableObject {
    
    let chain: Chain
    let nodeService: NodeService
    
    @Published var chainNode: ChainNode {
        didSet {
            try? nodeService.setNodeSelected(chain: chain, node: chainNode.node)
        }
    }
    @Published var nodes: [ChainNode] = []
    
    @Published var selectedExplorer: String? = .none
    var explorers: [String]
    let explorerService: ExplorerService
    
    init(
        chain: Chain,
        nodeService: NodeService,
        explorerService: ExplorerService
    ) {
        self.chain = chain
        self.nodeService = nodeService
        self.explorerService = explorerService
        self.chainNode = nodeService.getNodeSelected(chain: chain)
        self.explorers = ExplorerService.explorers(chain: chain)
        self.selectedExplorer = explorerService.get(chain: chain) ?? explorers.first
    }
    
    var title: String {
        Asset(chain).name
    }
    
    func getNodes() throws -> [ChainNode] {
        try nodeService.nodes(for: chain)
    }
    
    func selectExplorer(name: String) {
        selectedExplorer = name
        explorerService.set(chain: chain, name: name)
    }
}
