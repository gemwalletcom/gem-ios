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

    private let defaultNodes: [ChainNode]
    private var nodes: [ChainNode] = []
    private var nodeStatusByChainId: [String: NodeStatus] = [:]

    private static let nodeValueFormatter = ValueFormatter.full_US

    init(
        nodeService: NodeService,
        explorerService: ExplorerService,
        chain: Chain
    ) {
        self.nodeService = nodeService
        self.explorerService = explorerService

        self.chain = chain

        self.defaultNodes = NodeService.defaultNodes(chain: chain)
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
                nodeStatus: nodeStatusByChainId[node.id],
                valueFormatter: Self.nodeValueFormatter
            )
        }
        .sorted(by: { !canDelete(node: $0.chainNode) && canDelete(node: $1.chainNode) })
    }

    var explorerTitle: String { Localized.Settings.Networks.explorer }

    var isSupportedAddingCustomNode: Bool {
        AssetConfiguration.addCustomNodeChains.contains(chain.type)
    }

    func canDelete(node: ChainNode) -> Bool {
        !node.isGemNode && !defaultNodes.contains(where: { $0 == node })
    }
}

// MARK: - Business logic

extension ChainSettingsViewModel {
    func fetchNodes() throws {
        nodes = try nodeService.nodes(for: chain)
    }

    func fetchNodesStatusInfo() async {
        await withTaskGroup(of: (ChainNode, NodeStatus?).self) { group in
            for node in nodes {
                group.addTask { [self] in
                    let data = await fetchNodeStatusInfo(for: node)
                    return (node, data)
                }
            }

            for await (node, data) in group {
                await MainActor.run {
                    nodeStatusByChainId[node.id] = data
                }
            }
        }
    }

    func select(node: ChainNode) throws {
        selectedNode = node
        try nodeService.setNodeSelected(chain: chain, node: selectedNode.node)
    }

    func delete() throws {
        guard let nodeDelete else { return }
        try nodeService.delete(chain: chain, node: nodeDelete.node)

        // select default, if selected node deleted
        if nodeDelete == selectedNode {
            selectedNode = nodeService.getNodeSelected(chain: chain)
        }
        try fetchNodes()
    }

    func selectExplorer(name: String) {
        selectedExplorer = name
        explorerService.set(chain: chain, name: name)
    }
}

// MARK: - Private

extension ChainSettingsViewModel {
    private func fetchNodeStatusInfo(for node: ChainNode) async -> (NodeStatus?) {
        guard let url = URL(string: node.node.url) else { return nil }
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let chainResult = try await LatencyMeasureService.measure(for: service.getLatestBlock)
            return .result(blockNumber: chainResult.value, latency: chainResult.latency)
        } catch {
            return .error(error: error)
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
