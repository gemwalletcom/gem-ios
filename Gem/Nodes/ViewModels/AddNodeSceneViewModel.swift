// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GemstonePrimitives
import BigInt

class AddNodeSceneViewModel: ObservableObject {
    private let nodeService: NodeService
    private let addNodeService: AddNodeService

    let chain: Chain
    @Published var urlString: String = ""
    @Published var state: StateViewType<AddNodeResult> = .noData

    private lazy var valueFormatter: ValueFormatter = {
        ValueFormatter(locale: Locale(identifier: "en_US"), style: .full)
    }()

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

    var title: String {
        Localized.Nodes.ImportNode.title
    }
}

// MARK: - Business Logic

extension AddNodeSceneViewModel {
    func importFoundNode() throws {
        // TODO: - implement disable after user selects "import node button", we can't use state: StateViewType<ImportNodeResult> progress
        let node = Node(url: urlString, status: .active, priority: 5)
        try addNodeService.addNode(ChainNodes(chain: chain.rawValue, nodes: [node]))

        // TODO: - impement correct way of selection node 
        /*
        try nodeService.setNodeSelected(chain: chain, node: node)
         */
    }

    func getNetworkInfo() async throws  {
        guard let url = URL(string: urlString) else {
            await updateStateWithError(error: AddNodeError.invalidNetworkId)
            return
        }

        await MainActor.run { [self] in
            self.state = .loading
        }

        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        async let isNodeSync = service.getInSync()
        async let chainId = service.getChainID()
        async let blockNumber = service.getLatestBlock()

        do {
            let (isSynced, networkId, blockNumber) = try await (isNodeSync, chainId, blockNumber)

            try validate(networkId: networkId)
            
            await MainActor.run { [self] in
                let blockNumber = valueFormatter.string(blockNumber, decimals: 0)
                let result = AddNodeResult(
                    chainID: networkId,
                    blockNumber: blockNumber,
                    isInSync: isSynced
                )
                self.state = .loaded(result)
            }
        } catch let error as AddNodeError {
            await updateStateWithError(error: error)
        } catch {
            await updateStateWithError(error: AddNodeError.invalidNetworkId)
        }
    }
}

// MARK: - Private

extension AddNodeSceneViewModel {
    private func updateStateWithError(error: LocalizedError) async {
        await MainActor.run { [self] in
            self.state = .error(error)
        }
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
