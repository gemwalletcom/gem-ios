// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Localization
import Blockchain
import ChainService
import NodeService
import PrimitivesComponents
import Validators
import Style

@MainActor
@Observable
public final class AddNodeSceneViewModel {
    private let nodeService: NodeService
    private let addNodeService: AddNodeService

    public let chain: Chain

    public var urlInputModel = InputValidationViewModel(mode: .onDemand, validators: [.url])
    public var state: StateViewType<AddNodeResultViewModel> = .noData
    public var isPresentingScanner: Bool = false
    public var isPresentingAlertMessage: AlertMessage?
    public var debounceInterval: Duration? = .milliseconds(250)

    public init(chain: Chain, nodeService: NodeService) {
        self.chain = chain
        self.nodeService = nodeService
        self.addNodeService = AddNodeService(nodeStore: nodeService.nodeStore)
    }

    public var title: String { Localized.Nodes.ImportNode.title }

    public var actionButtonTitle: String { Localized.Wallet.Import.action }
    public var inputFieldTitle: String { Localized.Common.url }

    public var errorTitle: String { Localized.Errors.errorOccured }
    public var chainModel: ChainViewModel { ChainViewModel(chain: chain) }

    public var warningModel: ListItemModel {
        ListItemModel(
            title: Localized.Asset.Verification.warningTitle,
            titleStyle: .headline,
            titleExtra: Localized.Nodes.ImportNode.warningMessage,
            titleStyleExtra: .bodySecondary,
            imageStyle: ListItemImageStyle(
                assetImage: AssetImage(type: Emoji.WalletAvatar.warning.rawValue),
                imageSize: .image.semiMedium,
                alignment: .top,
                cornerRadiusType: .none
            )
        )
    }
}

// MARK: - Business Logic

extension AddNodeSceneViewModel {
    func onChangeInput(_ text: String) async {
        debounceInterval = .milliseconds(250)

        guard text.isNotEmpty, urlInputModel.isValid else {
            state = .noData
            return
        }
        await fetch()
    }

    func setInput(_ text: String) {
        debounceInterval = nil
        urlInputModel.text = text
    }

    func importFoundNode() throws {
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
    
    func fetch() async {
        guard let url = try? URLDecoder().decode(urlInputModel.text) else {
            // safety check for onSubmitUrl
            state = .error(AnyError(AddNodeError.invalidURL.errorDescription ?? ""))
            return
        }

        state = .loading
        let provider = ChainServiceFactory(nodeProvider: CustomNodeULRFetchable(url: url))
        let service = provider.service(for: chain)

        do {
            let nodeStatus = try await service.getNodeStatus(url: urlInputModel.text)
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
