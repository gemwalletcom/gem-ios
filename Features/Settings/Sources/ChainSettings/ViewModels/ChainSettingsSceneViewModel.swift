// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import ChainService
import NodeService
import ExplorerService
import Formatters

@Observable
@MainActor
public final class ChainSettingsSceneViewModel {
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
    private var statusStateByNodeId: [String: NodeStatusState] = [:]

    private static let formatter = ValueFormatter.full_US

    public init(
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
                statusState: statusStateByNodeId[node.id] ?? .none,
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

extension ChainSettingsSceneViewModel {
    func fetchNodes() throws {
        nodes = try nodeService.nodes(for: chain)
    }

    func clear() {
        statusStateByNodeId = [:]
    }

    func fetchNodesStates() async {
        await withTaskGroup(of: (ChainNode, NodeStatusState).self) { [weak self] group in
            guard let self else { return }
            for node in self.nodes {
                group.addTask { [weak self] in
                    guard let self else { return (node, .none) }
                    return (node, await fetchNodeStatusState(for: node))
                }
            }

            for await (node, state) in group {
                statusStateByNodeId[node.id] = state
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

extension ChainSettingsSceneViewModel {
    private func fetchNodeStatusState(for node: ChainNode) async -> NodeStatusState {
        guard let url = URL(string: node.node.url) else {
            return .error(error: URLError(.badURL))
        }
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let nodeStatus = try await service.getNodeStatus(url: node.node.url)
            return .result(nodeStatus)
        } catch {
            return .error(error: error)
        }
    }
}
