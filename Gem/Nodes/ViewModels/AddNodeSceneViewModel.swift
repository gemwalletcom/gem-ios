// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GemstonePrimitives
import BigInt
import Blockchain

class AddNodeSceneViewModel: ObservableObject {
    private let nodeService: NodeService
    private let addNodeService: AddNodeService
    
    let chain: Chain

    @Published var urlInput: String = ""
    @Published var state: StateViewType<AddNodeResult> = .noData
    @Published var isPresentingScanner: Bool = false
    @Published var isPresentingErrorAlert: String?

    private let valueFormatter = ValueFormatter.full_US

    init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.addNodeService = AddNodeService(nodeStore: nodeService.nodeStore)
    }
    
    var shouldDisableImportButton: Bool {
        guard let value = state.value else {
            return state.isNoData || state.isError
        }
        return !value.isInSync
    }
    
    var title: String { Localized.Nodes.ImportNode.title }
    
    var actionButtonTitle: String { Localized.Wallet.Import.action }
    var doneButtonTitle: String { Localized.Common.done }
    var inputFieldTitle: String { Localized.Common.url }
    
    var errorTitle: String { Localized.Errors.errorOccured }
    
    var chainIdTitle: String { Localized.Nodes.ImportNode.chainId }
    var chainIdValue: String? { state.value?.chainID }

    var inSyncTitle: String { Localized.Nodes.ImportNode.inSync }
    var inSyncValue: String? {
        guard let value = state.value else { return nil }
        return value.isInSync ? "✅" : "❌"
    }

    var latestBlockTitle: String { Localized.Nodes.ImportNode.latestBlock }

    var latencyTitle: String { Localized.Nodes.ImportNode.latency }
    var latecyValue: String? {
        guard let value = state.value else { return nil }
        let latency = value.latency
        return "\(Localized.Common.latencyInMs(latency.value)) \(latency.colorEmoji)"
    }

}

// MARK: - Business Logic

extension AddNodeSceneViewModel {
    func importFoundNode() throws {
        // TODO: - implement disable after user selects "import node button", we can't use state: StateViewType<ImportNodeResult> progress
        let node = Node(url: urlInput, status: .active, priority: 5)
        try addNodeService.addNode(ChainNodes(chain: chain.rawValue, nodes: [node]))

        // TODO: - impement correct way of selection node 
        /*
        try nodeService.setNodeSelected(chain: chain, node: node)
         */
    }

    func fetch() async  {
        guard let url = URL(string: urlInput) else {
            await updateStateWithError(error: AnyError(AddNodeError.invalidURL.errorDescription ?? ""))
            return
        }

        await MainActor.run { [self] in
            self.state = .loading
        }

        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let (latency, chainId) = try await fetchChainID(service: service)
            let nodeInfo = try await fetchAdditionalNodeInfo(service: service)

            let result = AddNodeResult(
                chainID: chainId,
                blockNumber: nodeInfo.formattedBlockNumber,
                isInSync: nodeInfo.isNodeInSync,
                latency: latency
            )

            await MainActor.run { [self] in
                self.state = .loaded(result)
            }
        } catch {
            await updateStateWithError(error: error)
        }
    }
}

// MARK: - Private

extension AddNodeSceneViewModel {
    private func fetchChainID(service: ChainIDFetchable) async throws -> (latency: LatencyMeasureService.Latency, value: String?) {
        let result = try await LatencyMeasureService.measure(for: service.getChainID)
        try validate(networkId: result.value)
        return result
    }

    private func validate(networkId: String?) throws {
        // if networkId in ChainConfig optional or from the service, proceed with valid id
        guard
            let networkId,
            let configNetworkId = ChainConfig.config(chain: chain).networkId else {
            return
        }
        if configNetworkId != networkId {
            throw AddNodeError.invalidNetworkId
        }
    }

    private func fetchAdditionalNodeInfo(service: ChainSyncable & ChainLatestBlockFetchable) async throws -> (isNodeInSync: Bool, formattedBlockNumber: String) {
        async let isNodeSync = service.getInSync()
        async let latestBlock = service.getLatestBlock()

        let (isNodeInSync, blockNumber) = try await (isNodeSync, latestBlock)
        let formattedBlockNumber = valueFormatter.string(blockNumber, decimals: 0)

        return (isNodeInSync: isNodeInSync, formattedBlockNumber: formattedBlockNumber)
    }

    private func updateStateWithError(error: Error) async {
        await MainActor.run { [self] in
            self.state = .error(error)
        }
    }
}

// MARK: - NodeURLFetchable

extension AddNodeSceneViewModel {
    struct CustomNodeULRFetchable: NodeURLFetchable {
        let url: URL

        func node(for chain: Chain) -> URL {
            return url
        }
    }
}
