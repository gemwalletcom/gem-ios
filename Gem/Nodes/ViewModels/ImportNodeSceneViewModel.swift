// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import BigInt

class ImportNodeSceneViewModel: ObservableObject {
    private let nodeService: NodeService
    private let importNodeService: ImportNodeService

    @Published private var chain: Chain

    @Published var urlString: String = ""
    @Published var state: StateViewType<Bool> = .noData
    @Published var chainID: String = ""
    @Published var blockNumber: String?
    @Published var isInSync: Bool = false

    init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.importNodeService = ImportNodeService(nodeStore: nodeService.nodeStore)
    }

    var shouldDisableImportButton: Bool {
        return state.isLoading || state.isNoData || state.isError
    }

    var title: String {
        Localized.Settings.Networks.ImportNode.title
    }
}

// MARK: - Business Logic

extension ImportNodeSceneViewModel {
    func importFoundNode()  {
        let node = Node(url: urlString, status: .active, priority: 10)
        try? importNodeService.importNode(ChainNodes(chain: chain.rawValue, nodes: [node]))
        try? nodeService.setNodeSelected(chain: chain, node: node)
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

            guard networkId == getPrimaryNetworkId(for: chain) else {
                await updateStateWithError()
                return
            }

            await MainActor.run { [self] in
                self.isInSync = isSynced
                self.chainID = networkId
                self.blockNumber = blockNumber
                self.state = .loaded(true)
            }
        } catch {
            await updateStateWithError()
        }
    }
}

// MARK: - Private

extension ImportNodeSceneViewModel {
    private func updateStateWithError() async {
        await MainActor.run {
            self.state = .error(AnyError(Localized.Errors.invalidUrl))
        }
    }

    private func getPrimaryNetworkId(for chain: Chain) -> String {
        switch chain {
        case .bitcoin: return "0"
        case .litecoin: return "2"
        case .ethereum: return "1"
        case .smartChain: return "56"
        case .solana: return "101"
        case .polygon: return "137"
        case .thorchain: return "931"
        case .cosmos: return "118"
        case .osmosis: return "297"
        case .arbitrum: return "42161"
        case .ton: return "3"
        case .tron: return "1111"
        case .doge: return "3"
        case .optimism: return "10"
        case .aptos: return "777"
        case .base: return "8453"
        case .avalancheC: return "43114"
        case .sui: return "2000"
        case .xrp: return "144"
        case .opBNB: return "97"
        case .fantom: return "250"
        case .gnosis: return "100"
        case .celestia: return "113"
        case .injective: return "333"
        case .sei: return "789"
        case .manta: return "205"
        case .blast: return "42220"
        case .noble: return "119"
        case .zkSync: return "324"
        case .linea: return "59144"
        case .mantle: return "5000"
        case .celo: return "42220"
        case .near: return "1313161554"
        }
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
