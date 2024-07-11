// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Settings
import Blockchain
import BigInt

@Observable
class ChainSettingsViewModel {
    let explorerService: ExplorerService
    let nodeService: NodeService

    let chain: Chain

    var isPresentingImportNode: Bool = false

    var selectedExplorer: String?
    var selectedNode: ChainNode
    var nodeDelete: ChainNode?

    var explorers: [String]

    private var nodes: [ChainNode] = []
    private var nodeMetricsByChainId: [String: NodeMetrics] = [:]

    private static let nodeValueFormatter = ValueFormatter.full_US

    init(
        nodeService: NodeService,
        explorerService: ExplorerService,
        chain: Chain
    ) {
        self.nodeService = nodeService
        self.explorerService = explorerService

        self.chain = chain
        self.selectedNode = nodeService.getNodeSelected(chain: chain)
        self.explorers = ExplorerService.explorers(chain: chain)
        self.selectedExplorer = explorerService.get(chain: chain) ?? explorers.first
    }

    var title: String { Asset(chain).name }

    var nodesTitle: String { Localized.Settings.Networks.source }
    var nodesModels: [ChainNodeViewModel] {
        nodes.map { node in
            ChainNodeViewModel(
                chainNode: node,
                nodeMetrics: nodeMetricsByChainId[node.id],
                valueFormatter: Self.nodeValueFormatter
            )
        }
    }

    var explorerTitle: String { Localized.Settings.Networks.explorer }

    var isSupportedAddingCustomNode: Bool {
        AssetConfiguration.addCustomNodeChains.contains(chain.type)
    }
}

// MARK: - Business logic

extension ChainSettingsViewModel {
    func fetchNodes() throws {
        nodes = try nodeService.nodes(for: chain)
    }

    func fetchNodesMetrics() async {
        await withTaskGroup(of: (ChainNode, NodeMetrics?).self) { group in
            for node in nodes {
                group.addTask { [self] in
                    let data = await fetchMetrics(for: node)
                    return (node, data)
                }
            }

            for await (node, data) in group {
                await MainActor.run {
                    nodeMetricsByChainId[node.id] = data
                }
            }
        }
    }

    func selectNode(node: ChainNode) throws {
        selectedNode = node
        try nodeService.setNodeSelected(chain: chain, node: selectedNode.node)
    }

    func deleteNode() throws {
        guard let nodeDelete else { return }
        try nodeService.delete(chain: chain, node: nodeDelete.node)
        nodes.removeAll { $0.id == nodeDelete.id }
    }

    func reselectNode() throws {
        if let nodeToSelect = nodes.first(where: { $0.isGemNode }) {
            try nodeService.setNodeSelected(chain: chain, node: nodeToSelect.node)
            selectedNode = nodeService.getNodeSelected(chain: chain)
        }
        nodes = try nodeService.nodes(for: chain)
    }

    func selectExplorer(name: String) {
        selectedExplorer = name
        explorerService.set(chain: chain, name: name)
    }
}

// MARK: - Private

extension ChainSettingsViewModel {
    private func fetchMetrics(for node: ChainNode) async -> (NodeMetrics?) {
        guard let url = URL(string: node.node.url) else {
            return nil
        }
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let chainResult = try await LatencyMeasureService.measure(for: service.getLatestBlock)
            return NodeMetrics(latency: chainResult.latency, blockNumber: chainResult.value, error: nil)
        } catch {
            return NodeMetrics(latency: nil, blockNumber: nil, error: error)
        }
    }
}

// MARK: - NodeURLFetchable

extension ChainSettingsViewModel {
    struct CustomNodeULRFetchable: NodeURLFetchable {
        let url: URL

        func node(for chain: Chain) -> URL {
            return url
        }
    }
}
