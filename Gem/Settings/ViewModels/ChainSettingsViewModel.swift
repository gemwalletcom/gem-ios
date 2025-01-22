// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Settings
import Localization
import ChainService
import ChainSettings
import NodeService
import ExplorerService

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
    private var nodeStatusByNodeId: [String: NodeStatus] = [:]

    private static let formatter = ValueFormatter.full_US

    init(
        nodeService: NodeService,
        explorerService: ExplorerService = .standard,
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
                nodeStatus: nodeStatusByNodeId[node.id] ?? .none,
                formatter: Self.formatter
            )
        }
        .sorted(by: { !canDelete(node: $0.chainNode) && canDelete(node: $1.chainNode) })
    }

    var explorerTitle: String { Localized.Settings.Networks.explorer }

    func canDelete(node: ChainNode) -> Bool {
        !node.isGemNode && !defaultNodes.contains(where: { $0 == node })
    }
}

// MARK: - Business logic

extension ChainSettingsViewModel {
    func fetchNodes() throws {
        nodes = try nodeService.nodes(for: chain)
    }
    
    func clear() {
        nodeStatusByNodeId = [:]
    }

    func fetchNodesStatusInfo() async {
        await withTaskGroup(of: (ChainNode, NodeStatus?).self) { group in
            for node in nodes {
                group.addTask { [self] in
                    return (node, await fetchNodeStatusInfo(for: node))
                }
            }

            for await (node, data) in group {
                await MainActor.run {
                    nodeStatusByNodeId[node.id] = data
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
    private func fetchNodeStatusInfo(for node: ChainNode) async -> NodeStatus? {
        guard let url = URL(string: node.node.url) else { return nil }
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let measure = try await LatencyMeasureService.measure(for: service.getLatestBlock)
            return .result(blockNumber: measure.value, latency: .from(duration: measure.duration))
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
