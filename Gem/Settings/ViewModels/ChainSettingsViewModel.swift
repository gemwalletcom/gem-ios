// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Settings
import Blockchain
import BigInt

@Observable
class ChainSettingsViewModel {
    private typealias ChainFetchData = (chainNode: ChainNode, latency: LatencyMeasureService.Latency?, blockNumber: BigInt?, error: Error?)

    let explorerService: ExplorerService
    let nodeService: NodeService

    let chain: Chain

    var isPresentingImportNode: Bool = false

    var selectedExplorer: String?
    var explorers: [String]

    var selectedNode: ChainNode
    var nodeDelete: ChainNode?

    private var nodes: [ChainNode] = []
    private var nodesChainIdData: [String: ChainFetchData] = [:]

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
            let chainData = nodesChainIdData[node.id]
            return ChainNodeViewModel(
                chainNode: node,
                blockNumber: chainData?.blockNumber ?? .none,
                latency: chainData?.latency ?? .none,
                blockNumberError: chainData?.error
            )
        }
    }

    var explorerTitle: String { Localized.Settings.Networks.explorer }

    var isSupportedAddingCustomNode: Bool {
        AssetConfiguration.addCustomNodeChains.contains(chain.type)
    }

    func canDelete(chainNode: ChainNode) -> Bool {
        guard nodes.count > 1 else { return false }
        return !chainNode.isGemNode
    }
}

// MARK: - Business logic

extension ChainSettingsViewModel {
    func fetch() async throws {
        try await MainActor.run { [self] in
            nodes = try nodeService.nodes(for: chain)
        }
        await fetchAvailableChainIds()
    }

    func selectNode(node: ChainNode) throws {
        selectedNode = node
        try nodeService.setNodeSelected(chain: chain, node: selectedNode.node)
    }

    func deleteNode() throws {
        guard let nodeDelete else { return }
        let shouldReselectNode = nodeDelete == selectedNode
        try nodeService.delete(node: nodeDelete.node, chain: chain)
        if shouldReselectNode {
            if let nodeToSelect = nodes.first(where: { $0.isGemNode }) ?? nodes.first(where: { $0 != nodeDelete }) {
                try nodeService.setNodeSelected(chain: chain, node: nodeToSelect.node)
                selectedNode = nodeService.getNodeSelected(chain: chain)
            }
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
    private func fetchAvailableChainIds() async {
        guard !nodes.isEmpty else { return }
        await withTaskGroup(of: (ChainFetchData).self) { [self] group in
            for node in nodes {
                group.addTask { [self] in
                    await fetchChainId(for: node)
                }
            }

            for await (chainFetchData) in group {
                await MainActor.run { [self] in
                    self.nodesChainIdData[chainFetchData.chainNode.id] = chainFetchData
                }
            }
        }
    }

    private func fetchChainId(for node: ChainNode) async -> (ChainFetchData) {
        guard let url = URL(string: node.node.url) else {
            return (ChainFetchData(node, .none, .none, .none))
        }
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let chainResult = try await LatencyMeasureService.measure(for: service.getLatestBlock)
            return (ChainFetchData(node, chainResult.latency, chainResult.value, .none))
        } catch {
            return (ChainFetchData(node, .none, .none, error))
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
