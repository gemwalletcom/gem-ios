// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GemstonePrimitives
import BigInt
import Blockchain
import Localization
import ChainService
import ChainSettings

final class AddNodeSceneViewModel: ObservableObject {
    private let nodeService: NodeService
    private let addNodeService: AddNodeService

    let chain: Chain

    @Published var urlInput: String = ""
    @Published var state: StateViewType<AddNodeResultViewModel> = .noData
    @Published var isPresentingScanner: Bool = false
    @Published var isPresentingErrorAlert: String?

    init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.addNodeService = AddNodeService(nodeStore: nodeService.nodeStore)
    }

    var title: String { Localized.Nodes.ImportNode.title }

    var actionButtonTitle: String { Localized.Wallet.Import.action }
    var doneButtonTitle: String { Localized.Common.done }
    var inputFieldTitle: String { Localized.Common.url }

    var errorTitle: String { Localized.Errors.errorOccured }
}

// MARK: - Business Logic

extension AddNodeSceneViewModel {
    func importFoundNode() throws {
        guard case .loaded(let model) = state else {
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
    
    func fetch() async  {
        guard let url = try? URLDecoder().decode(urlInput) else {
            await updateStateWithError(error: AnyError(AddNodeError.invalidURL.errorDescription ?? ""))
            return
        }

        await MainActor.run { [self] in
            self.state = .loading
        }

        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            async let (requestLatency, networkId) = fetchChainID(service: service)
            async let inSync = service.getInSync()
            async let latestBlock = service.getLatestBlock()

            let (latency, chainId, isNodeInSync, blockNumber) = try await (requestLatency, networkId, inSync, latestBlock)

            let result = AddNodeResult(url: url, chainID: chainId, blockNumber: blockNumber, isInSync: isNodeInSync, latency: latency)
            let resultVM = AddNodeResultViewModel(addNodeResult: result)

            await MainActor.run { [self] in
                self.state = .loaded(resultVM)
            }
        } catch {
            await updateStateWithError(error: error)
        }
    }
}

// MARK: - Private

extension AddNodeSceneViewModel {
    private func fetchChainID(service: any ChainIDFetchable) async throws -> (latency: Latency, value: String) {
        let result = try await LatencyMeasureService.measure(for: service.getChainID)
        try validate(networkId: result.value)
        return (latency: .from(duration: result.duration), value: result.value)
    }

    private func validate(networkId: String) throws {
        let configNetworkId = ChainConfig.config(chain: chain).networkId
        if configNetworkId != networkId {
            throw AddNodeError.invalidNetworkId
        }
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

        func node(for chain: Chain) -> URL {
            return url
        }
    }
}
