// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Localization
import Blockchain
import ChainService
import NodeService
import PrimitivesComponents

@MainActor
@Observable
public final class AddNodeSceneViewModel {
    private let nodeService: NodeService
    private let addNodeService: AddNodeService

    public let chain: Chain

    public var urlInput: String = ""
    public var state: StateViewType<AddNodeResultViewModel> = .noData
    public var isPresentingScanner: Bool = false
    public var isPresentingAlertMessage: AlertMessage?

    public init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.addNodeService = AddNodeService(nodeStore: nodeService.nodeStore)
    }

    public var title: String { Localized.Nodes.ImportNode.title }

    public var actionButtonTitle: String { Localized.Wallet.Import.action }
    public var doneButtonTitle: String { Localized.Common.done }
    public var inputFieldTitle: String { Localized.Common.url }

    public var errorTitle: String { Localized.Errors.errorOccured }
    public var chainModel: ChainViewModel { ChainViewModel(chain: chain) }
}

// MARK: - Business Logic

extension AddNodeSceneViewModel {
    public func importFoundNode() throws {
        guard case .data(let model) = state else {
            throw AnyError("Unknown result")
        }
        
        // TODO: - implement disable after user selects "import node button", we can't use state: StateViewType<ImportNodeResult> progress
        let node = Node(url: model.url.absoluteString, status: .active, priority: 5)
        try addNodeService.addNode(ChainNodes(chain: chain.rawValue, nodes: [node]))

        // TODO: - impement correct way of selection node
        /*
        try nodeService.setNodeSelected(chain: chain, node: node)
         */
    }
    
    public func fetch() async  {
        guard let url = try? URLDecoder().decode(urlInput) else {
            await updateStateWithError(error: AnyError(AddNodeError.invalidURL.errorDescription ?? ""))
            return
        }

        state = .loading
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            async let (requestLatency, networkId) = fetchChainID(service: service)
            async let latestBlock = service.getLatestBlock()

            let (latency, chainId, isNodeInSync, blockNumber) = try await (requestLatency, networkId, true, latestBlock)

            let result = AddNodeResult(url: url, chainID: chainId, blockNumber: blockNumber, isInSync: isNodeInSync, latency: latency)
            let resultVM = AddNodeResultViewModel(addNodeResult: result)
            state = .data(resultVM)
        } catch {
            await updateStateWithError(error: error)
        }
    }
}

// MARK: - Private

extension AddNodeSceneViewModel {
    private func fetchChainID(service: any ChainIDFetchable) async throws -> (latency: Latency, value: String) {
        let result = try await LatencyMeasureService.measure(for: service.getChainID)
        let networkId = result.value
        guard NodeService.isValid(netoworkId: networkId, for: chain) else {
            throw AddNodeError.invalidNetworkId
        }
        return (latency: .from(duration: result.duration), value: networkId)
    }

    private func updateStateWithError(error: any Error) async {
        await MainActor.run { [self] in
            self.state = .error(error)
        }
    }
}

// MARK: - NodeURLFetchable

extension AddNodeSceneViewModel {
    struct CustomNodeULRFetchable: NodeURLFetchable {
        let url: URL
        func node(for chain: Chain) -> URL { url }
    }
}
