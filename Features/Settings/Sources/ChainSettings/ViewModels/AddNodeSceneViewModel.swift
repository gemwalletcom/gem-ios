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
            state = .error(AnyError(AddNodeError.invalidURL.errorDescription ?? ""))
            return
        }

        state = .loading
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let nodeStatus = try await service.getNodeStatus(url: urlInput)
            guard NodeService.isValid(netoworkId: nodeStatus.chainId, for: chain) else {
                throw AddNodeError.invalidNetworkId
            }
            
            let result = AddNodeResult(
                url: url, 
                chainID: nodeStatus.chainId, 
                blockNumber: nodeStatus.latestBlockNumber, 
                isInSync: true, 
                latency: nodeStatus.latency
            )
            state = .data(AddNodeResultViewModel(addNodeResult: result))
        } catch {
            state = .error(error)
        }
    }
}
