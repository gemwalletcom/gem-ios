// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GemstonePrimitives

class ImportNodeSceneViewModel: ObservableObject {
    private let nodeService: NodeService
    private let importNodeService: ImportNodeService

    @Published private var chain: Chain
    @Published var urlString: String = ""
    @Published var state: StateViewType<ImportNodeResult> = .noData

    init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.importNodeService = ImportNodeService(nodeStore: nodeService.nodeStore)
    }

    var shouldDisableImportButton: Bool {
        guard let value = state.value else { return true }
        return !value.isInSync
    }

    var title: String {
        Localized.Nodes.ImportNode.title
    }
}

// MARK: - Business Logic

extension ImportNodeSceneViewModel {
    func importFoundNode() throws {
        let node = Node(url: urlString, status: .active, priority: 5)
        try importNodeService.importNode(ChainNodes(chain: chain.rawValue, nodes: [node]))

        // TODO: - impement correct way of selection node 
        /*
        try nodeService.setNodeSelected(chain: chain, node: node)
         */
    }

    func getNetworkInfo() async throws  {
        guard let url = URL(string: urlString) else {
            await updateStateWithError()
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

            guard validate(networkId: networkId) else {
                await updateStateWithError()
                return
            }

            await MainActor.run { [self] in
                let result = ImportNodeResult(chainID: networkId, blockNumber: blockNumber, isInSync: isSynced)
                self.state = .loaded(result)
            }
        } catch {
            await updateStateWithError()
        }
    }
}

// MARK: - Private

extension ImportNodeSceneViewModel {
    private func updateStateWithError() async {
        await MainActor.run { [self] in
            self.state = .error(AnyError(Localized.Errors.invalidUrl))
        }
    }

    private func validate(networkId: String) -> Bool {
        // if networkId in ChainConfig optional, proceed with valid id
        guard let id = ChainConfig.config(chain: chain).networkId else { return true }
        return id == networkId
    }
}

// MARK: - NodeURLFetchable

extension ImportNodeSceneViewModel {
    struct CustomNodeULRFetchable: NodeURLFetchable {
        let url: URL

        func node(for chain: Chain) -> URL {
            return url
        }
    }
}
