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
    private let explorerService: ExplorerService

    let nodeService: NodeService
    let chainServiceFactory: ChainServiceFactory
    let chain: Chain

    var selectedExplorer: String?
    var selectedNode: ChainNode
    var nodeDelete: ChainNode?
    var explorers: [String]
    var isPresentingImportNode: Bool = false

    private let defaultNodes: [ChainNode]
    private let formatter = ValueFormatter.full_US

    private var nodes: [ChainNode] = []
    private var statusStateByNodeId: [String: NodeStatusState] = [:]

    public init(
        nodeService: NodeService,
        chainServiceFactory: ChainServiceFactory,
        explorerService: ExplorerService = .standard,
        chain: Chain
    ) {
        self.nodeService = nodeService
        self.chainServiceFactory = chainServiceFactory
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
                formatter: formatter
            )
        }
        .sorted(by: { !canDelete(node: $0.chainNode) && canDelete(node: $1.chainNode) })
    }

    var explorerTitle: String { Localized.Settings.Networks.explorer }
    var deleteButtonTitle: String { Localized.Common.delete }
    
    func deleteConfirmationTitle(for nodeName: String) -> String { Localized.Common.deleteConfirmation(nodeName) }

    func canDelete(node: ChainNode) -> Bool { !node.isGemNode && !defaultNodes.contains(where: { $0 == node }) }
}

// MARL: - Actions

extension ChainSettingsSceneViewModel {
    func fetch() async {
        do {
            clear()
            try fetchNodes()
            await fetchNodesStates()
        } catch {
            // TODO: - handle error
            debugLog("chain settings scene: fetch error \(error)")
        }
    }

    func onSelectExplorer(name: String) {
        selectedExplorer = name
        explorerService.set(chain: chain, name: name)
    }

    func onSelectNode(_ node: ChainNode) {
        do {
            selectedNode = node
            try nodeService.setNodeSelected(chain: chain, node: selectedNode.node)
        } catch {
            // TODO: - handle error
            debugLog("chain settings scene: on chain select error \(error)")
        }
    }

    func onSelectNodeForDeletion(_ chainNode: ChainNode) {
        nodeDelete = chainNode
    }

    func onPresentImportNode() {
        isPresentingImportNode = true
    }

    func onDismissImportNode() {
        isPresentingImportNode = false
        Task {
            await fetch()
        }
    }

    func onDeleteNode() {
        do {
            try delete()
        } catch {
            // TODO: - handle error
            debugLog("chain settings scene: on delete error \(error)")
        }
    }
}

// MARK: - Private

extension ChainSettingsSceneViewModel {
    private func fetchNodes() throws {
        nodes = try nodeService.nodes(for: chain)
    }

    private func clear() {
        statusStateByNodeId = [:]
    }

    private func fetchNodesStates() async {
        await withTaskGroup(of: (ChainNode, NodeStatusState).self) { group in
            for node in nodes {
                group.addTask {
                    (node, await self.fetchNodeStatusState(for: node))
                }
            }

            for await (node, state) in group {
                statusStateByNodeId[node.id] = state
            }
        }
    }

    private func delete() throws {
        guard let nodeDelete else { return }
        try nodeService.delete(chain: chain, node: nodeDelete.node)

        // select default, if selected node deleted
        if nodeDelete == selectedNode {
            selectedNode = nodeService.getNodeSelected(chain: chain)
        }
        try fetchNodes()
    }

    private func fetchNodeStatusState(for node: ChainNode) async -> NodeStatusState {
        guard let url = URL(string: node.node.url) else {
            return .error(error: URLError(.badURL))
        }
        let nodeProvider = CustomNodeULRFetchable(url: url, requestInterceptor: chainServiceFactory.requestInterceptor)
        let service = ChainServiceFactory(nodeProvider: nodeProvider).service(for: chain)

        do {
            let nodeStatus = try await service.getNodeStatus(url: node.node.url)
            return .result(nodeStatus)
        } catch {
            return .error(error: error)
        }
    }
}
